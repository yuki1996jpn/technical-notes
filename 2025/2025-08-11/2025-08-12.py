import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import os

# Tesseractのインストールパスを指定
# 通常はC:\Program Files\Tesseract-OCR\tesseract.exeです。
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# PDFファイル名と出力ファイル名
pdf_path = 'your_book.pdf'
output_text_file = 'extracted_text.txt'

def ocr_pdf_with_crop(pdf_path, output_text_file):
    """
    指定されたPDFファイルをOCRし、テキストとして抽出します。
    ページ上部の5%は読み取り対象から外し、不要な改行を削除します。
    最初の10ページのみを処理します。
    """
    print(f"{pdf_path}のOCRを開始します...")

    try:
        if not os.path.exists(pdf_path):
            print(f"エラー: '{pdf_path}' が見つかりません。ファイル名を正しく設定してください。")
            return

        doc = fitz.open(pdf_path)
        all_text = []

        # 最初の10ページのみを処理
        # min(doc.page_count, 10)で、PDFのページ数が10未満の場合は全ページを処理します。
        pages_to_process = min(doc.page_count, 10)

        for page_num in range(pages_to_process):
            print(f"ページ {page_num + 1}/{doc.page_count} を処理中...")

            # ページを画像にレンダリング
            page = doc.load_page(page_num)
            pix = page.get_pixmap(dpi=300) # dpiを高くすると精度が向上します
            img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)

            # ページ上部8%をクロップ
            width, height = img.size
            cropped_img = img.crop((0, int(height * 0.08), width, height))

            # OCR実行
            page_text = pytesseract.image_to_string(cropped_img, lang='eng') # lang='eng'で英語を指定

            # テキストの整形
            # 不要な改行を削除し、文を自然につなげる
            cleaned_text = ' '.join(line.strip() for line in page_text.splitlines() if line.strip())
            
            # ハイフンで終わる単語の改行を削除
            cleaned_text = cleaned_text.replace('- ', '')
            
            if cleaned_text.strip():
                all_text.append(cleaned_text)
            else:
                print(f"ページ {page_num + 1} からテキストを抽出できませんでした。")

        doc.close()

        # 抽出したテキストをファイルに書き込む
        with open(output_text_file, 'w', encoding='utf-8') as f:
            f.write('\n\n'.join(all_text))
            
        print(f"OCRが完了しました。テキストは {output_text_file} に保存されました。")

    except Exception as e:
        print(f"エラーが発生しました: {e}")

if __name__ == '__main__':
    ocr_pdf_with_crop(pdf_path, output_text_file)
