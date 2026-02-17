import pytest

from omnizart.beat import app


@pytest.mark.parametrize("mode", [None, "BLSTM"])
def test_load_model(mode):
    with pytest.raises(FileNotFoundError):
        app._load_model(mode, custom_objects=app.custom_objects)
