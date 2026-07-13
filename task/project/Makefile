.PHONY: install test build clean

install:
	pip install -e .

test:
	pytest tests/ -v

build:
	python -m build

clean:
	rm -rf dist/ build/ *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
