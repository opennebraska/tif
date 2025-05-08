import spacy
from spacy.matcher import Matcher
import argparse

# Set up argument parser
parser = argparse.ArgumentParser(description='Process TIF-related sentences from a text file.')
parser.add_argument('input_file', help='Path to the input text file')
args = parser.parse_args()

# Load English language model
nlp = spacy.load("en_core_web_sm")
matcher = Matcher(nlp.vocab)

# Define simple example rules
rules = {
    "TIF_APPROVED": [
        [{"LEMMA": {"IN": ["approve", "grant", "authorize"]}}, {"OP": "*"}, {"LOWER": "tif"}],
        [{"LOWER": "tif"}, {"OP": "*"}, {"LEMMA": {"IN": ["approve", "grant", "authorize"]}}],
    ],
    "TIF_DENIED": [
        [{"LEMMA": {"IN": ["deny", "reject", "withhold"]}}, {"OP": "*"}, {"LOWER": "tif"}],
        [{"LOWER": "tif"}, {"OP": "*"}, {"LEMMA": {"IN": ["deny", "reject", "withhold"]}}],
    ],
    "TIF_PROPOSED": [
        [{"LEMMA": {"IN": ["propose", "introduce", "submit"]}}, {"OP": "*"}, {"LOWER": "tif"}],
        [{"LOWER": "tif"}, {"OP": "*"}, {"LEMMA": {"IN": ["propose", "introduce", "submit"]}}],
    ],
    "TIF_AMENDED": [
        [{"LEMMA": {"IN": ["amend", "revise", "change"]}}, {"OP": "*"}, {"LOWER": "tif"}],
        [{"LOWER": "tif"}, {"OP": "*"}, {"LEMMA": {"IN": ["amend", "revise", "change"]}}],
    ]
}

# Add rules to matcher
for label, pattern in rules.items():
    matcher.add(label, pattern)

# Load text from file
with open(args.input_file, "r") as f:
    text = f.read()

doc = nlp(text)

# Process each sentence
for sent in doc.sents:
    if "TIF " not in sent.text:
        continue  # Skip sentences without "TIF "

    sent_doc = nlp(sent.text)  # Run matcher on sentence
    matches = matcher(sent_doc)
    
    if matches:
        for match_id, start, end in matches:
            label = nlp.vocab.strings[match_id]
            print(f"[{label}] {sent.text.strip()}")
    else:
        print(f"[UNCATEGORIZED] {sent.text.strip()}")
