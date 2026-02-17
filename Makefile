CHECK_SRC := ./omnizart
SPLEETER_GIT := git+https://github.com/deezer/spleeter.git@2786e37


.PHONY: all
all: lint test

# --------------------------------------------------------------
# Linter
# --------------------------------------------------------------

.PHONY: lint
lint: check-flake check-pylint

.PHONY: check-flake
check-flake:
	@echo "Checking with flake..."
	@flake8 --config .config/flake $(CHECK_SRC)

.PHONY: check-pylint
check-pylint:
	@echo "Checking with pylint..."
	@pylint --fail-under 9.5 --rcfile .config/pylintrc $(CHECK_SRC)

.PHONY: check-black
check-black:
	@echo "Checking with black..."
	@black --check $(CHECK_SRC)

.PHONY: format
format:
	@echo "Format code with black"
	@black $(CHECK_SRC)
	@echo "Format code with yapf"
	@yapf $(CHECK_SRC) --in-place --recursive --style .config/yapf.style

# --------------------------------------------------------------
# Unittest
# --------------------------------------------------------------

.PHONY: test
test:
	@echo "Run unit tests"
	@pytest --cov-fail-under=25 --cov-report=html --cov=omnizart tests

# --------------------------------------------------------------
# Other convenient utilities
# --------------------------------------------------------------

.PHONY: install
install:
	@pip install --upgrade pip setuptools wheel
	@pip install Cython numpy scipy numba
	@pip install madmom vamp --no-build-isolation
	@pip install .
	@pip install pandas norbert "ffmpeg-python>=0.2.0" "httpx[http2]" typer
	@pip install --no-deps "spleeter @ $(SPLEETER_GIT)"

.PHONY: install-dev
install-dev:
	@pip install --upgrade pip setuptools wheel
	@pip install Cython numpy scipy numba
	@pip install madmom vamp --no-build-isolation
	@pip install -e .
	@pip install pandas norbert "ffmpeg-python>=0.2.0" "httpx[http2]" typer
	@pip install --no-deps "spleeter @ $(SPLEETER_GIT)"

.PHONY: docs
docs:
	@$(MAKE) -C docs html

.PHONY: clean
clean:
	@rm -rf .venv/
	@rm -rf docs/build/

.PHONY: build-docker
build-docker:
	docker build --network=host -t omnizart:dev ./
