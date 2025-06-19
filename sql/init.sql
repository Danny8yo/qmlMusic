-- 启用外键约束，必须放在最前面
PRAGMA foreign_keys = ON;

-- 创建歌曲表
CREATE TABLE IF NOT EXISTS Songs (
    SongId INTEGER PRIMARY KEY AUTOINCREMENT,
    filePath TEXT NOT NULL,
    title TEXT NOT NULL,
    artist TEXT,
    album TEXT,
    coverUrl TEXT
);

--创建歌单列表表
CREATE TABLE IF NOT EXISTS Playlists(
    PlaylistId INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    coverUrl TEXT,
    creationDate DATETIME DEFAULT CURRENT_TIMESTAMP--DEFAULT CURRENT_TIMESTAMP 将在插入时自动设置为当前时间
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
-- INSERT OR IGNORE INTO 防止重复插入相同数据
INSERT OR IGNORE INTO Songs (filePath, title, artist, album, coverUrl) VALUES
-- 本地音乐歌单
('/test_Music/Local_Playlist/爱意 (金风玉露变奏) - 陈致逸.mp3', '爱意 (金风玉露变奏)', '陈致逸', '金风玉露变奏', '/test_Music/Local_Playlist/covers/爱意 (金风玉露变奏) - 陈致逸.jpg'),
('/test_Music/Local_Playlist/城里的月光 - 许美静.mp3', '城里的月光', '许美静', '城里的月光', '/test_Music/Local_Playlist/covers/城里的月光 - 许美静.jpg'),
('/test_Music/Local_Playlist/当时的月亮 - 张悬.mp3', '当时的月亮', '张悬', '当时的月亮', '/test_Music/Local_Playlist/covers/当时的月亮 - 张悬.jpg'),
('/test_Music/Local_Playlist/工厂 - 河南说唱之神.mp3', '工厂', '河南说唱之神', '工厂', '/test_Music/Local_Playlist/covers/工厂 - 河南说唱之神.jpg'),
('/test_Music/Local_Playlist/过程 - 蛋堡.mp3', '过程', '蛋堡', '过程', '/test_Music/Local_Playlist/covers/过程 - 蛋堡.jpg'),
('/test_Music/Local_Playlist/会好 - 夏之禹.mp3', '会好', '夏之禹', '会好', '/test_Music/Local_Playlist/covers/会好 - 夏之禹.jpg'),
('/test_Music/Local_Playlist/離歌（翻自 在） - 在.mp3', '離歌（翻自 在）', '在', '離歌', '/test_Music/Local_Playlist/covers/離歌（翻自 在） - 在.jpg'),
('/test_Music/Local_Playlist/挪威的森林 - 伍佰 & China Blue.mp3', '挪威的森林', '伍佰 & China Blue', '挪威的森林', '/test_Music/Local_Playlist/covers/挪威的森林 - 伍佰 & China Blue.jpg'),
-- 精选歌单
('/test_Music/Local_Playlist/素颜 - 许嵩、何曼婷.mp3', '素颜', '许嵩、何曼婷', '素颜', '/test_Music/Local_Playlist/covers/素颜 - 许嵩、何曼婷.jpg'),
('/test_Music/Local_Playlist/唯一-告五人.mp3', '唯一', '告五人', '唯一', '/test_Music/Local_Playlist/covers/唯一-告五人.jpg'),
('/test_Music/Local_Playlist/我是一只鱼 - 落日飞车.mp3', '我是一只鱼', '落日飞车', '我是一只鱼', '/test_Music/Local_Playlist/covers/我是一只鱼 - 落日飞车.jpg'),
('/test_Music/Local_Playlist/虚拟 - 陈粒.mp3', '虚拟', '陈粒', '虚拟', '/test_Music/Local_Playlist/covers/虚拟 - 陈粒.jpg'),
('/test_Music/Local_Playlist/艳火 - 张悬.mp3', '艳火', '张悬', '艳火', '/test_Music/Local_Playlist/covers/艳火 - 张悬.jpg'),
('/test_Music/Local_Playlist/忆山水 - 贊詩.mp3', '忆山水', '贊詩', '忆山水', '/test_Music/Local_Playlist/covers/忆山水 - 贊詩.jpg'),
-- 流行歌单
('/test_Music/Local_Playlist/雨燕 - 南青乐队.mp3', '雨燕', '南青乐队', '雨燕', '/test_Music/Local_Playlist/covers/雨燕 - 南青乐队.jpg'),
('/test_Music/Local_Playlist/越过山丘-——致 李宗盛先生 - 杨宗纬.mp3', '越过山丘-——致 李宗盛先生', '杨宗纬', '越过山丘', '/test_Music/Local_Playlist/covers/越过山丘-——致 李宗盛先生 - 杨宗纬.jpg'),
('/test_Music/Local_Playlist/最好的时光 - 安溥 anpu.mp3', '最好的时光', '安溥 anpu', '最好的时光', '/test_Music/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg'),
('/test_Music/Local_Playlist/Blue Dragon(piano&guitarver) - 澤野弘之.mp3', 'Blue Dragon(piano&guitarver)', '澤野弘之', 'Blue Dragon', '/test_Music/Local_Playlist/covers/Blue Dragon(piano&guitarver) - 澤野弘之.jpg'),
('/test_Music/Local_Playlist/Closer - The Chainsmokers、Halsey.mp3', 'Closer', 'The Chainsmokers、Halsey', 'Closer', '/test_Music/Local_Playlist/covers/Closer - The Chainsmokers、Halsey.jpg'),
('/test_Music/Local_Playlist/Counting Stars - OneRepublic.mp3', 'Counting Stars', 'OneRepublic', 'Counting Stars', '/test_Music/Local_Playlist/covers/Counting Stars - OneRepublic.jpg'),
('/test_Music/Local_Playlist/I Know You Know I Love You - 落日飞车.mp3', 'I Know You Know I Love You', '落日飞车', 'I Know You Know I Love You', '/test_Music/Local_Playlist/covers/I Know You Know I Love You - 落日飞车.jpg'),
-- 其他歌曲
('/test_Music/Local_Playlist/I Really want to stay at your house.mp3', 'I Really want to stay at your house', 'Unknown Artist', 'I Really want to stay at your house', '/test_Music/Local_Playlist/covers/I Really want to stay at your house.jpg'),
('/test_Music/Local_Playlist/Let There Be Light Again - 落日飞车.mp3', 'Let There Be Light Again', '落日飞车', 'Let There Be Light Again', '/test_Music/Local_Playlist/covers/Let There Be Light Again - 落日飞车.jpg'),
('/test_Music/Local_Playlist/Ma Meilleure Ennemie - Stromae、Pomme.mp3', 'Ma Meilleure Ennemie', 'Stromae、Pomme', 'Ma Meilleure Ennemie', '/test_Music/Local_Playlist/covers/Ma Meilleure Ennemie - Stromae、Pomme.jpg'),
('/test_Music/Local_Playlist/Stay With Me-《孤单又灿烂的神－鬼怪》韩剧插曲 - CHANYEOL、펀치.mp3', 'Stay With Me-《孤单又灿烂的神－鬼怪》韩剧插曲', 'CHANYEOL、펀치', 'Stay With Me', '/test_Music/Local_Playlist/covers/Stay With Me-《孤单又灿烂的神－鬼怪》韩剧插曲 - CHANYEOL、펀치.jpg'),
('/test_Music/Local_Playlist/The Nights.mp3', 'The Nights', 'Unknown Artist', 'The Nights', '/test_Music/Local_Playlist/covers/The Nights.jpg'),
('/test_Music/Local_Playlist/Vogel im Kafig - 澤野弘之、Cyua.mp3', 'Vogel im Kafig', '澤野弘之、Cyua', 'Vogel im Kafig', '/test_Music/Local_Playlist/covers/Vogel im Kafig - 澤野弘之、Cyua.jpg');

-- 插入歌单表
INSERT OR IGNORE INTO Playlists (name, description, coverUrl) VALUES
('本地音乐', '本地音乐播放列表', '/test_Music/Local_Playlist/covers/唯一-告五人.jpg'),
('精选歌曲', '精选的音乐作品', '/test_Music/Local_Playlist/covers/爱意 (金风玉露变奏) - 陈致逸.jpg'),
('流行歌曲', '流行音乐的代表作品', '/test_Music/Local_Playlist/covers/城里的月光 - 许美静.jpg'),
('其他歌曲', '其他精选歌曲', '/test_Music/Local_Playlist/covers/挪威的森林 - 伍佰 & China Blue.jpg');

-- 插入播放列表-歌曲关联表
INSERT OR IGNORE INTO PlaylistSongs (PlaylistID, SongId, SongOrder) VALUES
-- 本地歌单映射
(1,1, 1),
(1,2, 2),
(1,3, 3),
(1,4, 4),
(1,5, 5),
(1,6, 6),
(1,7, 7),
(1,8, 8),
-- 精选歌单映射
(2,9, 1),
(2,10, 2),
(2,11, 3),
(2,12, 4),
(2,13, 5),
(2,14, 6),
-- 流行歌单映射
(3,15, 1),
(3,16, 2),
(3,17, 3),
(3,18, 4),
(3,19, 5),
(3,20, 6),
(3,21, 7),
-- 其他歌曲映射
(4,22, 1),
(4,23, 2),
(4,24, 3),
(4,25, 4),
(4,26, 5),
(4,27, 6);