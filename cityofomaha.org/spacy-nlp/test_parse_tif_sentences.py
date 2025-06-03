import pytest
from parse_tif_sentences import nlp, matcher
from collections import Counter

def process_file(file_path):
    """Helper function to process a file and return categorized sentences"""
    with open(file_path, "r") as f:
        text = f.read()
    
    doc = nlp(text)
    categories = []
    
    for sent in doc.sents:
        if "TIF " not in sent.text:
            continue
            
        sent_doc = nlp(sent.text)
        matches = matcher(sent_doc)
        
        if matches:
            for match_id, start, end in matches:
                label = nlp.vocab.strings[match_id]
                categories.append(label)
        else:
            categories.append("UNCATEGORIZED")
            
    return Counter(categories)

def test_approved_tifs():
    """Test that examples_approved.txt contains 2 approved TIFs"""
    categories = process_file("examples_approved.txt")
    print(categories)
    assert categories["TIF_APPROVED"] == 2, "Should find 2 approved TIFs in examples_approved.txt"

def test_laid_over_tifs():
    """Test that examples_laid_over.txt contains 3 TIFs laid over for public hearing"""
    categories = process_file("examples_laid_over.txt")
    assert categories["TIF_PROPOSED"] == 3, "Should find 3 TIFs laid over for public hearing in examples_laid_over.txt"

def test_reduced_tif():
    """Test that examples_reduces.txt contains 1 TIF with reduced budget"""
    with open("examples_reduces.txt", "r") as f:
        text = f.read()
    
    # Look for the specific reduction amount
    assert "reduces the original TIF loan from $3,099,288.00 to $2,248,788.00" in text, \
        "Should find TIF reduction of approximately $850,000 in examples_reduces.txt"
    
    # Verify it's categorized as amended
    categories = process_file("examples_reduces.txt")
    assert categories["TIF_AMENDED"] == 1, "Should find 1 amended TIF in examples_reduces.txt" 