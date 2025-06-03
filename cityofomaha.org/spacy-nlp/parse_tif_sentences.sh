# docker run -it --rm -v "$PWD":/app -v"$PWD/dump":/app/dump tif-parser python3 parse_tif_sentences.py dump/2025-01-14j.txt

docker run -it --rm -v "$PWD":/app -v"$PWD/dump":/app/dump tif-parser pytest test_parse_tif_sentences.py -v

