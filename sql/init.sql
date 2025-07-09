-- 启用外键约束，必须放在最前面
PRAGMA foreign_keys = ON;

-- 创建歌曲表
CREATE TABLE IF NOT EXISTS Songs (
    SongId INTEGER PRIMARY KEY AUTOINCREMENT,
    filePath TEXT NOT NULL,
    title TEXT NOT NULL,
    artist TEXT,
    album TEXT,
    coverUrl TEXT,
    isFavorite BOOLEAN
);

--创建歌单列表表
CREATE TABLE IF NOT EXISTS Playlists(
    PlaylistId INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    coverUrl TEXT,
    creationDate DATETIME DEFAULT CURRENT_TIMESTAMP,--DEFAULT CURRENT_TIMESTAMP 将在插入时自动设置为当前时间
    ifLocal BOOLEAN DEFAULT FALSE -- 标识是否为本地创建的歌单
    -- lastModified DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 创建播放列表-歌曲关联表
CREATE TABLE IF NOT EXISTS PlaylistSongs(
    PlaylistSongId INTEGER PRIMARY KEY AUTOINCREMENT,
    PlaylistID INTEGER NOT NULL,
    SongId INTEGER NOT NULL,
    SongOrder INTEGER NOT NULL,
    FOREIGN KEY (PlaylistID) REFERENCES Playlists(PlaylistId),
    FOREIGN KEY (SongId) REFERENCES Songs(SongId)
);

-- 插入歌曲数据
-- 首先删除旧数据，以便重新插入
DELETE FROM PlaylistSongs;
DELETE FROM Playlists;
DELETE FROM Songs;

-- 重置自增列
DELETE FROM sqlite_sequence WHERE name='Songs';
DELETE FROM sqlite_sequence WHERE name='Playlists';
DELETE FROM sqlite_sequence WHERE name='PlaylistSongs';


-- 插入新的歌曲数据
INSERT INTO Songs (filePath, title, artist, album, coverUrl, isFavorate) VALUES
('/test_Music/Local_Playlist/エターナルポーズ - Asia Engineer.mp3', 'エターナルポーズ', 'Asia Engineer', 'エターナルポーズ', '/test_Music/Local_Playlist/covers/エターナルポーズ - Asia Engineer.jpg', 0),
('/test_Music/Local_Playlist/小半-陈粒.mp3', '小半', '陈粒', '小半', '/test_Music/Local_Playlist/covers/小半-陈粒.jpg', 0),
('/test_Music/Local_Playlist/月灯りふんわり落ちてくる夜 - 音羽ゆりかご会.mp3', '月灯りふんわり落ちてくる夜', '音羽ゆりかご会', '月灯りふんわり落ちてくる夜', '/test_Music/Local_Playlist/covers/月灯りふんわり落ちてくる夜 - 音羽ゆりかご会.jpg', 0),
('/test_Music/Local_Playlist/爸爸妈妈 - 李荣浩.mp3', '爸爸妈妈', '李荣浩', '爸爸妈妈', '/test_Music/Local_Playlist/covers/爸爸妈妈 - 李荣浩.jpg', 0),
('/test_Music/Local_Playlist/画-赵雷.mp3', '画', '赵雷', '画', '/test_Music/Local_Playlist/covers/画-赵雷.jpg', 0),
('/test_Music/Local_Playlist/百年孤寂.mp3', '百年孤寂', 'Unknown', '百年孤寂', '/test_Music/Local_Playlist/covers/百年孤寂.jpg', 0),
('/test_Music/Local_Playlist/走马.mp3', '走马', 'Unknown', '走马', '/test_Music/Local_Playlist/covers/走马.jpg', 0),
('/test_Music/Local_Playlist/野子.mp3', '野子', 'Unknown', '野子', '/test_Music/Local_Playlist/covers/野子.jpg', 0);

-- 插入歌单表
INSERT INTO Playlists (name, description, coverUrl, ifLocal) VALUES
('精选歌曲', '精选的中外歌曲', '/test_Music/Local_Playlist/covers/エターナルポーズ - Asia Engineer.jpg', 0),
('流行歌曲', '流行音乐代表作', '/test_Music/Local_Playlist/covers/小半-陈粒.jpg', 0),
('轻音乐', '轻松愉悦的音乐', '/test_Music/Local_Playlist/covers/月灯りふんわり落ちてくる夜 - 音羽ゆりかご会.jpg', 0),
('民谣音乐', '民谣音乐代表作', '/test_Music/Local_Playlist/covers/爸爸妈妈 - 李荣浩.jpg', 0),
('世界音乐', '世界音乐代表作', '/test_Music/Local_Playlist/covers/画-赵雷.jpg', 0),
('经典老歌', '经典老歌代表作', '/test_Music/Local_Playlist/covers/百年孤寂.jpg', 0),
('电子音乐', '电子音乐代表作', '/test_Music/Local_Playlist/covers/走马.jpg', 0),
('耳熟的英文歌', '耳熟的英文歌代表作', '/test_Music/Local_Playlist/covers/野子.jpg', 1);

-- 插入播放列表-歌曲关联表
INSERT INTO PlaylistSongs (PlaylistID, SongId, SongOrder) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 7, 1),
(8, 8, 1);
