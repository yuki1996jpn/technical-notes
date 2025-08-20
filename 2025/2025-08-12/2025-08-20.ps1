import pandas as pd
from googleapiclient.discovery import build
import time

# --- 設定 ---
API_KEY = "ここに取得したAPIキーを貼り付けます"
CHANNEL_ID = "ここに取得したチャンネルIDを貼り付けます"

# --- APIクライアントの構築 ---
youtube = build('youtube', 'v3', developerKey=API_KEY)

# データを格納するリスト
all_comments_data = []

# -----------------
# 1. チャンネルの「アップロード済み動画」プレイリストIDを取得
# -----------------
def get_uploads_playlist_id(channel_id):
    request = youtube.channels().list(
        part="contentDetails",
        id=channel_id
    )
    response = request.execute()
    if 'items' in response and response['items']:
        return response['items'][0]['contentDetails']['relatedPlaylists']['uploads']
    return None

# -----------------
# 2. プレイリストからすべての動画IDを取得
# -----------------
def get_all_video_ids(playlist_id):
    video_ids = []
    request = youtube.playlistItems().list(
        part="contentDetails",
        playlistId=playlist_id,
        maxResults=50  # 1度のリクエストで取得する最大件数
    )
    while request:
        response = request.execute()
        for item in response.get('items', []):
            video_ids.append(item['contentDetails']['videoId'])
        
        request = youtube.playlistItems().list_next(request, response)
    return video_ids

# -----------------
# 3. 各動画のコメントを取得し、リストに追加
# -----------------
def get_comments_for_video(video_id):
    video_comments = []
    print(f"動画ID: {video_id} のコメントを取得中...")
    
    try:
        request = youtube.commentThreads().list(
            part="snippet",
            videoId=video_id,
            maxResults=100
        )
        while request:
            response = request.execute()
            for item in response.get('items', []):
                snippet = item['snippet']
                top_level_comment = snippet['topLevelComment']['snippet']

                # データを抽出
                video_comments.append({
                    'video_id': video_id,
                    'comment_id': item['id'],
                    'author_name': top_level_comment['authorDisplayName'],
                    'comment_text': top_level_comment['textDisplay'],
                    'like_count': top_level_comment['likeCount'],
                    'published_at': top_level_comment['publishedAt']
                })
            
            request = youtube.commentThreads().list_next(request, response)
    except Exception as e:
        print(f"  --> エラー: {e} (コメントが無効になっている可能性があります。)")
    
    return video_comments


if __name__ == '__main__':
    uploads_playlist_id = get_uploads_playlist_id(CHANNEL_ID)
    if not uploads_playlist_id:
        print("アップロード済み動画プレイリストが見つかりませんでした。チャンネルIDを確認してください。")
    else:
        video_ids = get_all_video_ids(uploads_playlist_id)
        if not video_ids:
            print("チャンネルに動画がありません。")
        else:
            print(f"チャンネル内の動画数: {len(video_ids)} 件")
            
            for video_id in video_ids:
                comments = get_comments_for_video(video_id)
                all_comments_data.extend(comments)
                
                # APIクォータ消費を抑えるために待機（任意）
                time.sleep(1)

            # --- CSVファイルへの出力 ---
            if all_comments_data:
                df = pd.DataFrame(all_comments_data)
                output_filename = f'{CHANNEL_ID}_all_comments.csv'
                df.to_csv(output_filename, index=False, encoding='utf-8-sig')
                print(f'\nすべてのコメントデータを {output_filename} に保存しました。')
            else:
                print('\nコメントが見つかりませんでした。')
