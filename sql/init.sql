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
-- INSERT OR IGNORE INTO 防止重复插入相同数据
INSERT OR IGNORE INTO Songs (filePath, title, artist, album, coverUrl) VALUES
('/test_Music/Local_Playlist/爱意 (金风玉露变奏) - 陈致逸.mp3', '爱意 (金风玉露变奏)', '陈致逸', '金风玉露变奏', '/test_Music/Local_Playlist/covers/爱意 (金风玉露变奏) - 陈致逸.jpg'),
('/test_Music/Local_Playlist/爸爸妈妈 - 李荣浩.mp3', '爸爸妈妈', '李荣浩', '爸爸妈妈', '/test_Music/Local_Playlist/covers/爸爸妈妈 - 李荣浩.jpg'),
('/test_Music/Local_Playlist/百年孤寂.mp3', '百年孤寂', 'Unknown Artist', '百年孤寂', '/test_Music/Local_Playlist/covers/百年孤寂.jpg'),
('/test_Music/Local_Playlist/城里的月光 - 许美静.mp3', '城里的月光', '许美静', '城里的月光', '/test_Music/Local_Playlist/covers/城里的月光 - 许美静.jpg'),
('/test_Music/Local_Playlist/处处吻 - 杨千嬅.mp3', '处处吻', '杨千嬅', '处处吻', '/test_Music/Local_Playlist/covers/处处吻 - 杨千嬅.jpg'),
('/test_Music/Local_Playlist/当时的月亮 - 张悬.mp3', '当时的月亮', '张悬', '当时的月亮', '/test_Music/Local_Playlist/covers/当时的月亮 - 张悬.jpg'),
('/test_Music/Local_Playlist/朵儿.mp3', '朵儿', 'Unknown Artist', '朵儿', '/test_Music/Local_Playlist/covers/朵儿.jpg'),
('/test_Music/Local_Playlist/富士山下 - 陈奕迅.mp3', '富士山下', '陈奕迅', '富士山下', '/test_Music/Local_Playlist/covers/富士山下 - 陈奕迅.jpg'),
('/test_Music/Local_Playlist/工厂 - 河南说唱之神.mp3', '工厂', '河南说唱之神', '工厂', '/test_Music/Local_Playlist/covers/工厂 - 河南说唱之神.jpg'),
('/test_Music/Local_Playlist/光辉岁月 - BEYOND.mp3', '光辉岁月', 'BEYOND', '光辉岁月', '/test_Music/Local_Playlist/covers/光辉岁月 - BEYOND.jpg'),
('/test_Music/Local_Playlist/过程 - 蛋堡.mp3', '过程', '蛋堡', '过程', '/test_Music/Local_Playlist/covers/过程 - 蛋堡.jpg'),
('/test_Music/Local_Playlist/海阔天空-《九五2班》网络电影插曲 - BEYOND.mp3', '海阔天空-《九五2班》网络电影插曲', 'BEYOND', '海阔天空', '/test_Music/Local_Playlist/covers/海阔天空-《九五2班》网络电影插曲 - BEYOND.jpg'),
('/test_Music/Local_Playlist/画-赵雷.mp3', '画', '赵雷', '画', '/test_Music/Local_Playlist/covers/画-赵雷.jpg'),
('/test_Music/Local_Playlist/会好 - 夏之禹.mp3', '会好', '夏之禹', '会好', '/test_Music/Local_Playlist/covers/会好 - 夏之禹.jpg'),
('/test_Music/Local_Playlist/老男孩 - 筷子兄弟.mp3', '老男孩', '筷子兄弟', '老男孩', '/test_Music/Local_Playlist/covers/老男孩 - 筷子兄弟.jpg'),
('/test_Music/Local_Playlist/離歌（翻自 在） - 在.mp3', '離歌（翻自 在）', '在', '離歌', '/test_Music/Local_Playlist/covers/離歌（翻自 在） - 在.jpg'),
('/test_Music/Local_Playlist/凌晨计程车.mp3', '凌晨计程车', 'Unknown Artist', '凌晨计程车', '/test_Music/Local_Playlist/covers/凌晨计程车.jpg'),
('/test_Music/Local_Playlist/南方姑娘.mp3', '南方姑娘', 'Unknown Artist', '南方姑娘', '/test_Music/Local_Playlist/covers/南方姑娘.jpg'),
('/test_Music/Local_Playlist/挪威的森林 - 伍佰 & China Blue.mp3', '挪威的森林', '伍佰 & China Blue', '挪威的森林', '/test_Music/Local_Playlist/covers/挪威的森林 - 伍佰.jpg'),
('/test_Music/Local_Playlist/若月亮没来 (若是月亮还没来) - 王宇宙Leto、乔浚丞.mp3', '若月亮没来 (若是月亮还没来)', '王宇宙Leto、乔浚丞', '若月亮没来', '/test_Music/Local_Playlist/covers/若月亮没来 (若是月亮还没来) - 王宇宙Leto、乔浚丞.jpg'),
('/test_Music/Local_Playlist/素颜 - 许嵩、何曼婷.mp3', '素颜', '许嵩、何曼婷', '素颜', '/test_Music/Local_Playlist/covers/素颜 - 许嵩、何曼婷.jpg'),
('/test_Music/Local_Playlist/唯一-告五人.mp3', '唯一', '告五人', '唯一', '/test_Music/Local_Playlist/covers/唯一-告五人.jpg'),
('/test_Music/Local_Playlist/我是一只鱼 - 落日飞车.mp3', '我是一只鱼', '落日飞车', '我是一只鱼', '/test_Music/Local_Playlist/covers/我是一只鱼 - 落日飞车.jpg'),
('/test_Music/Local_Playlist/无名的人-《雄狮少年》电影主题曲 - 毛不易.mp3', '无名的人-《雄狮少年》电影主题曲', '毛不易', '无名的人', '/test_Music/Local_Playlist/covers/无名的人-《雄狮少年》电影主题曲 - 毛不易.jpg'),
('/test_Music/Local_Playlist/羡慕风羡慕雨 - 怪阿姨.mp3', '羡慕风羡慕雨', '怪阿姨', '羡慕风羡慕雨', '/test_Music/Local_Playlist/covers/羡慕风羡慕雨 - 怪阿姨.jpg'),
('/test_Music/Local_Playlist/小半-陈粒.mp3', '小半', '陈粒', '小半', '/test_Music/Local_Playlist/covers/小半-陈粒.jpg'),
('/test_Music/Local_Playlist/虚拟 - 陈粒.mp3', '虚拟', '陈粒', '虚拟', '/test_Music/Local_Playlist/covers/虚拟 - 陈粒.jpg'),
('/test_Music/Local_Playlist/艳火 - 张悬.mp3', '艳火', '张悬', '艳火', '/test_Music/Local_Playlist/covers/艳火 - 张悬.jpg'),
('/test_Music/Local_Playlist/野子.mp3', '野子', 'Unknown Artist', '野子', '/test_Music/Local_Playlist/covers/野子.jpg'),
('/test_Music/Local_Playlist/忆山水 - 贊詩.mp3', '忆山水', '贊詩', '忆山水', '/test_Music/Local_Playlist/covers/忆山水 - 贊詩.jpg'),
('/test_Music/Local_Playlist/雨燕 - 南青乐队.mp3', '雨燕', '南青乐队', '雨燕', '/test_Music/Local_Playlist/covers/雨燕 - 南青乐队.jpg'),
('/test_Music/Local_Playlist/越过山丘-——致 李宗盛先生 - 杨宗纬.mp3', '越过山丘-——致 李宗盛先生', '杨宗纬', '越过山丘', '/test_Music/Local_Playlist/covers/越过山丘-——致 李宗盛先生 - 杨宗纬.jpg'),
('/test_Music/Local_Playlist/走马.mp3', '走马', 'Unknown Artist', '走马', '/test_Music/Local_Playlist/covers/走马.jpg'),
('/test_Music/Local_Playlist/最好的时光 - 安溥 anpu.mp3', '最好的时光', '安溥 anpu', '最好的时光', '/test_Music/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg'),
('/test_Music/Local_Playlist/Beautiful World - 宇多田ヒカル.mp3', 'Beautiful World', '宇多田ヒカル', 'Beautiful World', '/test_Music/Local_Playlist/covers/Beautiful World - 宇多田ヒカル.jpg'),
('/test_Music/Local_Playlist/Blue Dragon(piano&guitarver) - 澤野弘之.mp3', 'Blue Dragon(piano&guitarver)', '澤野弘之', 'Blue Dragon', '/test_Music/Local_Playlist/covers/Blue Dragon(piano&guitarver) - 澤野弘之.jpg'),
('/test_Music/Local_Playlist/Call Your Name - 泽野弘之、mpi、CASG.mp3', 'Call Your Name', '泽野弘之、mpi、CASG', 'Call Your Name', '/test_Music/Local_Playlist/covers/Call Your Name - 泽野弘之、mpi、CASG.jpg'),
('/test_Music/Local_Playlist/Call of Silence (AT Master remix) (Remix) - Master.mp3', 'Call of Silence (AT Master remix)', 'Master', 'Call of Silence', '/test_Music/Local_Playlist/covers/Call of Silence (AT Master remix) (Remix) - Master.jpg'),
('/test_Music/Local_Playlist/Closer - The Chainsmokers、Halsey.mp3', 'Closer', 'The Chainsmokers、Halsey', 'Closer', '/test_Music/Local_Playlist/covers/Closer - The Chainsmokers、Halsey.jpg'),
('/test_Music/Local_Playlist/Counting Stars - OneRepublic.mp3', 'Counting Stars', 'OneRepublic', 'Counting Stars', '/test_Music/Local_Playlist/covers/Counting Stars - OneRepublic.jpg'),
('/test_Music/Local_Playlist/I Know You Know I Love You - 落日飞车.mp3', 'I Know You Know I Love You', '落日飞车', 'I Know You Know I Love You', '/test_Music/Local_Playlist/covers/I Know You Know I Love You - 落日飞车.jpg'),
('/test_Music/Local_Playlist/I Really want to stay at your house.mp3', 'I Really want to stay at your house', 'Unknown Artist', 'I Really want to stay at your house', '/test_Music/Local_Playlist/covers/I Really want to stay at your house.jpg'),
('/test_Music/Local_Playlist/Let There Be Light Again - 落日飞车.mp3', 'Let There Be Light Again', '落日飞车', 'Let There Be Light Again', '/test_Music/Local_Playlist/covers/Let There Be Light Again - 落日飞车.jpg'),
('/test_Music/Local_Playlist/Ma Meilleure Ennemie - Stromae、Pomme.mp3', 'Ma Meilleure Ennemie', 'Stromae、Pomme', 'Ma Meilleure Ennemie', '/test_Music/Local_Playlist/covers/Ma Meilleure Ennemie - Stromae、Pomme.jpg'),
('/test_Music/Local_Playlist/Pork Soda - Glass Animals.mp3', 'Pork Soda', 'Glass Animals', 'Pork Soda', '/test_Music/Local_Playlist/covers/Pork Soda - Glass Animals.jpg'),
('/test_Music/Local_Playlist/Sincerely - TRUE.mp3', 'Sincerely', 'TRUE', 'Sincerely', '/test_Music/Local_Playlist/covers/Sincerely - TRUE.jpg'),
('/test_Music/Local_Playlist/Stay With Me-《孤单又灿烂的神－鬼怪》韩剧插曲 - CHANYEOL、펀치.mp3', 'Stay With Me-《孤单又灿烂的神－鬼怪》韩剧插曲', 'CHANYEOL、펀치', 'Stay With Me', '/test_Music/Local_Playlist/covers/Stay With Me-《孤单又灿烂的神－鬼怪》韩剧插曲 - CHANYEOL、펀치.jpg'),
('/test_Music/Local_Playlist/The Nights.mp3', 'The Nights', 'Unknown Artist', 'The Nights', '/test_Music/Local_Playlist/covers/The Nights.jpg'),
('/test_Music/Local_Playlist/The Other Side Of Paradise (Explicit) - Glass Animals.mp3', 'The Other Side Of Paradise (Explicit)', 'Glass Animals', 'The Other Side Of Paradise', '/test_Music/Local_Playlist/covers/The Other Side Of Paradise (Explicit) - Glass Animals.jpg'),
('/test_Music/Local_Playlist/Vogel im Kafig - 澤野弘之、Cyua.mp3', 'Vogel im Kafig', '澤野弘之、Cyua', 'Vogel im Kafig', '/test_Music/Local_Playlist/covers/Vogel im Kafig - 澤野弘之、Cyua.jpg'),
('/test_Music/Local_Playlist/CHA-LA HEAD-CHA-LA-《龙珠Z》- 影山ヒロノブ.mp3', 'CHA-LA HEAD-CHA-LA-《龙珠Z》', '影山ヒロノブ', 'CHA-LA HEAD-CHA-LA', '/test_Music/Local_Playlist/covers/CHA-LA HEAD-CHA-LA-《龙珠Z》- 影山ヒロノブ.jpg'),
('/test_Music/Local_Playlist/DAN DAN 心魅かれてく - Field of View.mp3', 'DAN DAN 心魅かれてく', 'Field of View', 'DAN DAN 心魅かれてく', '/test_Music/Local_Playlist/covers/DAN DAN 心魅かれてく - Field of View.jpg'),
('/test_Music/Local_Playlist/Devilman No Uta (Night Version Instrument) - agraph.mp3', 'Devilman No Uta (Night Version Instrument)', 'agraph', 'Devilman No Uta', '/test_Music/Local_Playlist/covers/Devilman No Uta (Night Version Instrument) - agraph.jpg'),
('/test_Music/Local_Playlist/Dragon Soul (TVサイズ) 谷本贵义 - 山本健司.mp3', 'Dragon Soul (TVサイズ)', '谷本贵义', 'Dragon Soul', '/test_Music/Local_Playlist/covers/Dragon Soul (TVサイズ) 谷本贵义 - 山本健司.jpg'),
('/test_Music/Local_Playlist/Hope-《海贼王》TV动画片头曲 - 安室奈美恵.mp3', 'Hope-《海贼王》TV动画片头曲', '安室奈美恵', 'Hope', '/test_Music/Local_Playlist/covers/Hope-《海贼王》TV动画片头曲 - 安室奈美恵.jpg'),
('/test_Music/Local_Playlist/Judgement (Night Version) - agraph.mp3', 'Judgement (Night Version)', 'agraph', 'Judgement', '/test_Music/Local_Playlist/covers/Judgement (Night Version) - agraph.jpg'),
('/test_Music/Local_Playlist/SPECIALZ - King Gnu.mp3', 'SPECIALZ', 'King Gnu', 'SPECIALZ', '/test_Music/Local_Playlist/covers/SPECIALZ - King Gnu.jpg'),
('/test_Music/Local_Playlist/なんでもないや  (Movie ver.)-《你的名字。》动画电影片尾曲 - RADWIMPS.mp3', 'なんでもないや  (Movie ver.)-《你的名字。》动画电影片尾曲', 'RADWIMPS', 'なんでもないや', '/test_Music/Local_Playlist/covers/なんでもないや  (Movie ver.)-《你的名字。》动画电影片尾曲 - RADWIMPS.jpg'),
('/test_Music/Local_Playlist/エターナルポーズ - Asia Engineer.mp3', 'エターナルポーズ', 'Asia Engineer', 'エターナルポーズ', '/test_Music/Local_Playlist/covers/エターナルポーズ - Asia Engineer.jpg'),
('/test_Music/Local_Playlist/スパークル (Movie ver.)-《你的名字。》动画电影插曲 - RADWIMPS.mp3', 'スパークル (Movie ver.)-《你的名字。》动画电影插曲', 'RADWIMPS', 'スパークル', '/test_Music/Local_Playlist/covers/スパークル (Movie ver.)-《你的名字。》动画电影插曲 - RADWIMPS.jpg'),
('/test_Music/Local_Playlist/ロマンティックあげるよ (单曲版) - 橋本潮.mp3', 'ロマンティックあげるよ (单曲版)', '橋本潮', 'ロマンティックあげるよ', '/test_Music/Local_Playlist/covers/ロマンティックあげるよ (单曲版) - 橋本潮.jpg'),
('/test_Music/Local_Playlist/夢灯籠-《你的名字。》动画电影片头曲 - RADWIMPS.mp3', '夢灯籠-《你的名字。》动画电影片头曲', 'RADWIMPS', '夢灯籠', '/test_Music/Local_Playlist/covers/夢灯籠-《你的名字。》动画电影片头曲 - RADWIMPS.jpg'),
('/test_Music/Local_Playlist/月灯りふんわり落ちてくる夜 - 音羽ゆりかご会.mp3', '月灯りふんわり落ちてくる夜', '音羽ゆりかご会', '月灯りふんわり落ちてくる夜', '/test_Music/Local_Playlist/covers/月灯りふんわり落ちてくる夜 - 音羽ゆりかご会.jpg'),
('/test_Music/Local_Playlist/前前前世 (Movie ver.)-《你的名字。》动画电影主题曲 - RADWIMPS.mp3', '前前前世 (Movie ver.)-《你的名字。》动画电影主题曲', 'RADWIMPS', '前前前世', '/test_Music/Local_Playlist/covers/前前前世 (Movie ver.)-《你的名字。》动画电影主题曲 - RADWIMPS.jpg'),
('/test_Music/Local_Playlist/悪魔の子 - ヒグチアイ.mp3', '悪魔の子', 'ヒグチアイ', '悪魔の子', '/test_Music/Local_Playlist/covers/悪魔の子 - ヒグチアイ.jpg'),
('/test_Music/Local_Playlist/魔诃不思议アドベンチャー！-《七龙珠》日本动漫主题曲 - 高桥洋树.mp3', '魔诃不思议アドベンチャー！-《七龙珠》日本动漫主题曲', '高桥洋树', '魔诃不思议アドベンチャー！', '/test_Music/Local_Playlist/covers/魔诃不思议アドベンチャー！-《七龙珠》日本动漫主题曲 - 高桥洋树.jpg');

-- 插入歌单表
INSERT OR IGNORE INTO Playlists (name, description, coverUrl) VALUES
('本地音乐', '本地中文音乐播放列表', '/test_Music/Local_Playlist/covers/爱意 (金风玉露变奏) - 陈致逸.jpg'),
('精选歌曲', '精选的中外文音乐作品', '/test_Music/Local_Playlist/covers/素颜 - 许嵩、何曼婷.jpg'),
('流行歌曲', '流行音乐的代表作品', '/test_Music/Local_Playlist/covers/Blue Dragon(piano&guitarver) - 澤野弘之.jpg'),
('动漫歌曲', '动漫主题曲和日文歌曲', '/test_Music/Local_Playlist/covers/前前前世 (Movie ver.)-《你的名字。》动画电影主题曲 - RADWIMPS.jpg'),
('经典老歌', '勾起人回忆的经典老歌', '/test_Music/Local_Playlist/covers/光辉岁月 - BEYOND.jpg'),
('轻音乐', '放松心情的轻音乐', '/test_Music/Local_Playlist/covers/Beautiful World - 宇多田ヒカル.jpg'),
('摇滚乐', '激励人心的摇滚乐曲目', '/test_Music/Local_Playlist/covers/SPECIALZ - King Gnu.jpg'),
('民谣音乐', '温暖人心的民谣歌曲', '/test_Music/Local_Playlist/covers/野子.jpg'),
('电子音乐', '动感十足的电子音乐', '/test_Music/Local_Playlist/covers/Pork Soda - Glass Animals.jpg'),
('世界音乐', '来自世界各地的音乐作品', '/test_Music/Local_Playlist/covers/Call Your Name - 泽野弘之、mpi、CASG.jpg'),
('耳熟的英文歌', '耳熟能详的英文歌曲', '/test_Music/Local_Playlist/covers/Closer - The Chainsmokers、Halsey.jpg');



-- 插入播放列表-歌曲关联表
INSERT OR IGNORE INTO PlaylistSongs (PlaylistID, SongId, SongOrder) VALUES
-- 歌单1: 本地音乐 (中文歌曲，SongId 1-20)
(1, 1, 1), (1, 2, 2), (1, 3, 3), (1, 4, 4), (1, 5, 5),
(1, 6, 6), (1, 7, 7), (1, 8, 8), (1, 9, 9), (1, 10, 10),
(1, 11, 11), (1, 12, 12), (1, 13, 13), (1, 14, 14), (1, 15, 15),
(1, 16, 16), (1, 17, 17), (1, 18, 18), (1, 19, 19), (1, 20, 20),

-- 歌单2: 精选歌曲 (精选中外文歌曲，SongId 21-33)
(2, 21, 1), (2, 22, 2), (2, 23, 3), (2, 24, 4), (2, 25, 5),
(2, 26, 6), (2, 27, 7), (2, 28, 8), (2, 29, 9), (2, 30, 10),
(2, 31, 11), (2, 32, 12), (2, 33, 13),

-- 歌单3: 流行歌曲 (流行音乐，SongId 34-49)
(3, 34, 1), (3, 35, 2), (3, 36, 3), (3, 37, 4), (3, 38, 5),
(3, 39, 6), (3, 40, 7), (3, 41, 8), (3, 42, 9), (3, 43, 10),
(3, 44, 11), (3, 45, 12), (3, 46, 13), (3, 47, 14), (3, 48, 15),
(3, 49, 16),

-- 歌单4: 动漫歌曲 (动漫主题曲和日文歌曲，SongId 50-63)
(4, 50, 1), (4, 51, 2), (4, 52, 3), (4, 53, 4), (4, 54, 5),
(4, 55, 6), (4, 56, 7), (4, 57, 8), (4, 58, 9), (4, 59, 10),
(4, 60, 11), (4, 61, 12), (4, 62, 13), (4, 63, 14),

-- 歌单5: 经典老歌 (经典怀旧歌曲)
(5, 10, 1), (5, 12, 2), (5, 15, 3), (5, 4, 4), (5, 8, 5),
(5, 18, 6), (5, 19, 7), (5, 3, 8),

-- 歌单6: 轻音乐 (放松心情的音乐)
(6, 34, 1), (6, 35, 2), (6, 42, 3), (6, 43, 4), (6, 59, 5),
(6, 60, 6), (6, 33, 7), (6, 30, 8),

-- 歌单7: 摇滚乐 (激励人心的摇滚乐)
(7, 56, 1), (7, 49, 2), (7, 44, 3), (7, 38, 4), (7, 39, 5),
(7, 9, 6), (7, 11, 7),

-- 歌单8: 民谣音乐 (温暖人心的民谣歌曲)
(8, 29, 1), (8, 32, 2), (8, 13, 3), (8, 17, 4), (8, 18, 5),
(8, 24, 6), (8, 28, 7), (8, 31, 8),

-- 歌单9: 电子音乐 (动感十足的电子音乐)
(9, 44, 1), (9, 48, 2), (9, 38, 3), (9, 39, 4), (9, 41, 5),
(9, 47, 6),

-- 歌单10: 世界音乐 (来自世界各地的音乐)
(10, 36, 1), (10, 37, 2), (10, 40, 3), (10, 43, 4), (10, 46, 5),
(10, 34, 6), (10, 50, 7), (10, 51, 8),

-- 歌单11: 耳熟的英文歌 (耳熟能详的英文歌曲)
(11, 38, 1), (11, 39, 2), (11, 41, 3), (11, 42, 4), (11, 47, 5),
(11, 48, 6), (11, 49, 7), (11, 44, 8);