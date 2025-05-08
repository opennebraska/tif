import spacy
from spacy.matcher import Matcher

# Load English language model
nlp = spacy.load("en_core_web_sm")
matcher = Matcher(nlp.vocab)

# Define simple example rules
rules = {
    "TIF_APPROVED": [
        [{"LOWER": "tif"}, {"LOWER": {"IN": ["approved", "granted", "authorized"]}}],
    ],
    "TIF_DENIED": [
        [{"LOWER": "tif"}, {"LOWER": {"IN": ["denied", "rejected", "withheld"]}}],
    ],
    "TIF_PROPOSED": [
        [{"LOWER": "tif"}, {"LOWER": {"IN": ["proposed", "introduced", "submitted"]}}],
    ],
    "TIF_AMENDED": [
        [{"LOWER": "tif"}, {"LOWER": {"IN": ["amended", "revised", "changed"]}}],
    ]
}

# Add rules to matcher
for label, pattern in rules.items():
    matcher.add(label, pattern)

# Load text from file (you can loop over your 100 files)
with open("example_document.txt", "r") as f:
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
