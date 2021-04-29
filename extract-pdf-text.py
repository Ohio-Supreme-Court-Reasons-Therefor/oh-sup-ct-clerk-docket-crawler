import pdfplumber

pdf = pdfplumber.open("2021-ohio-254.pdf")
page_margin_to_ignore_in_points = 65
page_text = ""
for pdf_page in pdf.pages:
    cropped_pdf_page = pdf_page.crop(
        (page_margin_to_ignore_in_points, 
        page_margin_to_ignore_in_points, 
        pdf_page.width-page_margin_to_ignore_in_points, 
        pdf_page.height-page_margin_to_ignore_in_points)
    )
    page_text += cropped_pdf_page.extract_text() + "\n"

print(page_text)


