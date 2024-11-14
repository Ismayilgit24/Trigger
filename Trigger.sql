Create Database Spotify
Use Spotify

Create Table Users(
Id int Primary Key identity,
[Name] Nvarchar(30) Not Null,
Surname Nvarchar(30) Not Null,
Username Varchar(50) Not Null,
[Password] Nvarchar(8) Not Null,
Gender Nvarchar(50) Not Null
)

Create Table Artists(
Id int Primary Key identity,
[Name] Nvarchar(30) Not Null,
Surname Nvarchar(30) Not Null,
Birthday DateTime Not Null,
Gender Nvarchar(50) Not Null
)

Insert Into Artists Values ('Elizabeth', 'Woolridge Grant', '1985-6-21', 'Female')
Insert Into Artists Values ('Abel', 'Makkonen Tesfaye', '1990-2-16', 'Male')
Insert Into Artists Values ('Taylor', 'Swift', '1987-5-10', 'Female')
Insert Into Artists Values ('Bruno', 'Mars', '1997-10-5', 'Male')


Create Table Categories(
Id int Primary Key identity,
[Name] Nvarchar(30) Not Null
)

Create Table Musics(
Id int Primary Key identity,
[Name] Nvarchar(100) Not Null,
Duration int Not Null,
CategoryId int References Categories(Id),
ArtistId int References Artists(Id),
UserId int References Users(Id)
)

Alter Table Musics Add IsDeleted bit


Alter Trigger SoftDelete
On Musics
Instead of Delete
As
Begin
Declare @isDeleted bit 
Declare @id int

Select @isDeleted = IsDeleted, @id = Id From Deleted

if(@isDeleted = 0) 
 Begin 
 Update Musics Set IsDeleted = 1 Where Id = @id
 End
 Else 
 Begin
 Delete From Musics Where Id = @id
 End
End


Delete From Musics Where Id = 6



Create Table Playlist(
Id int Primary Key identity,
MusicsId int References Musics(Id),
UsersId int References Users(Id),
ArtistId int References Artists(Id)
)

Drop Table Playlist

Create Procedure usp_CreateMusic 
(@name Nvarchar(100), @duration int, @categoryid int, @artistid int, @userid int) 
As
Insert Into Musics Values
(@name, @duration, @categoryid, @artistid, @userid)

Exec usp_CreateMusic 'Cardigan', 3, 1, 3, 1
Exec usp_CreateMusic 'Cardigan', 3, 1, 3, 2
Exec usp_CreateMusic 'Die With a Smile', 4, 1, 4, 3
Exec usp_CreateMusic 'Brooklyn Baby', 4, 2, 1, 4
Exec usp_CreateMusic 'Summer Wine', 3, 3, 1, 3
Exec usp_CreateMusic 'After Hours', 5, 4, 2, 2


Create Procedure usp_CreateUser 
(@name Nvarchar(30), @surname Nvarchar(30), @username Nvarchar(50), @password Nvarchar(8), @gender Nvarchar(50)) 
As
Insert Into Users Values
(@name, @surname, @username, @password, @gender)

Exec usp_CreateUser N'Nigar', N'Abbasl?', 'nigarabbasli', 'abbasli1', 'Female'
Exec usp_CreateUser N'K?rim', N'Ramazanov', 'ramazanov15', 'krmznv', 'Male'
Exec usp_CreateUser N'Ülvi', N'?liyev', 'aliyev', 'ulvi2005', 'Male'
Exec usp_CreateUser N'S?f?r', N'?hm?dli', 'sefer', 'akhmedli', 'Male'


Create Procedure usp_CreateCategory 
(@name Nvarchar(30)) 
As
Insert Into Categories Values
(@name)

Exec usp_CreateCategory 'Pop'
Exec usp_CreateCategory 'Classical'
Exec usp_CreateCategory '?nstrumental'
Exec usp_CreateCategory 'Jazz'




Create View MusicInformation As
Select m.Name As [Song], m.Duration As [Duration], a.Name + ' ' + a.Surname As [Full Name], c.Name As [Category] From Musics As m
Join Categories As c
On m.CategoryId = c.Id
Join Artists As a
On m.ArtistId = a.Id
Group By m.Name, c.Name, a.Name, a.Surname, m.Duration

Select * From MusicInformation


Alter Function dbo.ShowArtist(@id int)
Returns int
As
Begin 
Declare @CountofArtists int
Select @CountofArtists = Count(Distinct a.Id) From Artists As a
Join Playlist As p
On a.Id = p.ArtistId
Join Users As u
On p.UsersId = u.Id
Where u.Id = @id
Return @CountofArtists
End

Select dbo.ShowArtist(3) As [Artist Count]




Alter Procedure ListofMusics(@id int)
As 
Select m.Name From Musics As m
Join Playlist As pl
On m.Id = pl.MusicsId
Join Users As u 
On pl.UsersId = u.Id
Where u.Id = @id
Group By m.name

Exec ListofMusics 4


Select m.Name, Min(m.Duration) As Duration 
From Musics As m
Group By m.Name
Order By Duration


Select a.Name + ' ' + a.Surname,  As Artist From Artists As a
Join Playlist As pl
On a.Id = pl.ArtistId
Join Musics As m
On pl.MusicsId = m.Id
Group By a.Name, a.Surname



Select a.Name + ' ' + a.Surname AS Artist, COUNT(m.Id) AS [Music Count]
From Artists As a
Join Musics As m 
On a.Id = m.ArtistId
Group By a.Name, a.Surname
Having Count(m.Id) = (
    Select Max(MusicCount)
    From (
        Select Count(m.Id) As [MusicCount]
        From Artists As a
        Join Musics As m 
		On a.Id = m.ArtistId
        Group By a.Id
    ) As Counts
)





