#!/usr/bin/env python3
"""
CIQUAL Data Converter
====================

This script converts the official CIQUAL Excel data from ANSES to the JSON format
expected by the Lym Nutrition Flutter application.

Usage:
1. Download the official CIQUAL Excel file from:
   https://ciqual.anses.fr/cms/sites/default/files/inline-files/Table%20Ciqual%202020_FR_2020%2007%2007.xls

2. Install dependencies:
   pip install pandas openpyxl

3. Run the script:
   python convert_ciqual_data.py input_file.xls output_file.json

Requirements:
- pandas
- openpyxl (for Excel file reading)

Author: Generated for Lym Nutrition App
Date: 2024
"""

import pandas as pd
import json
import sys
import argparse
from pathlib import Path

def convert_ciqual_excel_to_json(excel_file_path: str, output_json_path: str):
    """
    Convert CIQUAL Excel data to JSON format expected by the Flutter app.
    
    Args:
        excel_file_path (str): Path to the official CIQUAL Excel file
        output_json_path (str): Path where the JSON file will be saved
    """
    
    print(f"Reading CIQUAL Excel file: {excel_file_path}")
    
    try:
        # Read the Excel file
        # The official CIQUAL Excel file typically has the data in the first sheet
        df = pd.read_excel(excel_file_path, sheet_name=0)
        
        print(f"Loaded {len(df)} rows from Excel file")
        print(f"Columns found: {list(df.columns)}")
        
        # Convert DataFrame to list of dictionaries
        foods_data = []
        
        for index, row in df.iterrows():
            # Create food item dictionary
            food_item = {}
            
            # Convert all values to appropriate types
            for column, value in row.items():
                if pd.isna(value):
                    # Handle NaN values
                    if 'code' in column.lower():
                        food_item[column] = ""
                    elif any(unit in column.lower() for unit in ['g/100 g', 'mg/100 g', 'µg/100 g', 'kcal/100 g']):
                        food_item[column] = "-"
                    else:
                        food_item[column] = ""
                elif isinstance(value, (int, float)):
                    # Convert numeric values to strings for consistency with the app
                    food_item[column] = str(value)
                else:
                    # Keep string values as strings
                    food_item[column] = str(value)
            
            foods_data.append(food_item)
        
        # Save to JSON file
        print(f"Converting to JSON format and saving to: {output_json_path}")
        
        with open(output_json_path, 'w', encoding='utf-8') as f:
            json.dump(foods_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Successfully converted {len(foods_data)} food items to JSON format")
        print(f"📁 Output file: {output_json_path}")
        
        # Display sample of first food item for verification
        if foods_data:
            print("\n📋 Sample of first food item:")
            first_item = foods_data[0]
            for key, value in list(first_item.items())[:10]:  # Show first 10 fields
                print(f"  {key}: {value}")
            if len(first_item) > 10:
                print(f"  ... and {len(first_item) - 10} more fields")
        
    except Exception as e:
        print(f"❌ Error converting CIQUAL data: {str(e)}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Convert official CIQUAL Excel data to JSON format for the Lym Nutrition app"
    )
    parser.add_argument(
        "excel_file", 
        help="Path to the official CIQUAL Excel file (.xls)"
    )
    parser.add_argument(
        "json_file",
        help="Output path for the JSON file"
    )
    parser.add_argument(
        "--validate-format",
        action="store_true",
        help="Validate that the output JSON matches the expected app format"
    )
    
    args = parser.parse_args()
    
    # Validate input file exists
    excel_path = Path(args.excel_file)
    if not excel_path.exists():
        print(f"❌ Error: Excel file not found: {args.excel_file}")
        sys.exit(1)
    
    # Ensure output directory exists
    json_path = Path(args.json_file)
    json_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Convert the data
    convert_ciqual_excel_to_json(args.excel_file, args.json_file)
    
    if args.validate_format:
        print("\n🔍 Validating JSON format...")
        validate_json_format(args.json_file)

def validate_json_format(json_file_path: str):
    """
    Validate that the generated JSON matches the expected format for the Flutter app.
    """
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if not isinstance(data, list):
            print("❌ JSON should be a list of food items")
            return
        
        if len(data) == 0:
            print("❌ JSON list is empty")
            return
        
        # Check first item structure
        first_item = data[0]
        required_fields = [
            'alim_code',
            'alim_nom_fr',
            'alim_grp_nom_fr',
            'alim_ssgrp_nom_fr'
        ]
        
        missing_fields = [field for field in required_fields if field not in first_item]
        if missing_fields:
            print(f"❌ Missing required fields: {missing_fields}")
            return
        
        print("✅ JSON format validation passed")
        print(f"📊 Total food items: {len(data)}")
        
    except Exception as e:
        print(f"❌ Validation error: {str(e)}")

if __name__ == "__main__":
    main()
