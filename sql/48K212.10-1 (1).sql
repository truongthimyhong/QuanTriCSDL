USE master;  
GO  
IF DB_ID (N'TapHoa') IS NOT NULL  
DROP DATABASE TapHoa; 
GO  
CREATE DATABASE TapHoa  
go
use TapHoa
go

--Tao bang NhaCungCap
create table NhaCungCap
(
	MaNCC	varchar(20) not null,
	TenNCC	varchar(50) not null,
	DiaChi	nvarchar(100) not null,
	SĐT		char(10) not null unique,
	MaNV	varchar(30),
	TenNV	varchar(50),
	primary key(MaNCC)
)
go
---Tao bang Hang
create table Hang
(
	MaHang		varchar(20) not null,
	TenHang		VARCHAR(50) not null,
	DonGiaNhap	NUMERIC,
	DonGiaBan	NUMERIC,
	DonVi		VARCHAR(20),
	primary key(MaHang)
)
go
---Tao bang KhachHang
create table KhachHang
(
	MaKH	char(15) not null,
	TenKH	NVARCHAR(50),
	SĐTKH	char(10) not null unique,
	primary key(MaKH)
)
go
---Tao bang HoaDonNo_NCC
create table HoaDonNo_NCC
(
	MaNoNCC		char(10) not null,
	SoTienCL	numeric not null,
	SoTienDaTT	numeric,
	primary key(MaNoNCC),
)
go
---Tao bang Hoadon_KHNo
create table Hoadon_KHNo
(
	MaNoKH		char(10) not null,
	SoTienCL	NUMERIC not null,
	SoTienDaTT	NUMERIC,
	primary key(MaNoKH)
)
go
---Tao bang NhapHang
create table NhapHang
(
	MaNhapHang	varchar(20) not null,
	MaNCC		varchar(20) not null,
	MaNoNCC		char(10) not null,
	KhuyenMai	numeric,
	TongTien	numeric not null,
	NgayGiao	date not null,
	primary key(MaNhapHang),
	FOREIGN KEY (MaNCC) REFERENCES NhaCungCap (MaNCC) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (MaNoNCC) REFERENCES HoaDonNo_NCC (MaNoNCC) ON DELETE CASCADE ON UPDATE CASCADE
)
go
---Tao bang NhapHang_chitiet
create table NhapHang_chitiet
(
	MaNhapHang	varchar(20) not null,
	MaHang		varchar(20) not null,
	SoLuong		int not null ,
	ThanhTien	NUMERIC not null,
	primary key(MaNhapHang,MaHang),
	FOREIGN KEY (MaHang) REFERENCES Hang (MaHang) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (MaNhapHang) REFERENCES NhapHang (MaNhapHang) ON DELETE CASCADE ON UPDATE CASCADE
)
go
---Tao bang BanHang
create table BanHang
(
	MaBanHang	varchar(20) not null,
	MaNoKH		char(10) not null,
	MaKH		char(15) not null,
	KhuyenMai	NUMERIC,
	TongTien	NUMERIC not null,
	NgayBan		DATE,
	primary key(MaBanHang),
	FOREIGN KEY (MaNoKH	) REFERENCES Hoadon_KHNo (MaNoKH) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (MaKH) REFERENCES KhachHang (MaKH) ON DELETE CASCADE ON UPDATE CASCADE
)
go
---Tao bang BanHang_chitiet
create table BanHang_chitiet
(
	MaBanHang	varchar(20) not null,
	MaHang		varchar(20) not null,
	SoLuong		int not null ,
	ThanhTien	NUMERIC not null,
	primary key(MaBanHang,MaHang),
	FOREIGN KEY (MaHang) REFERENCES Hang (MaHang) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (MaBanHang) REFERENCES BanHang (MaBanHang) ON DELETE CASCADE ON UPDATE CASCADE
)
go
-- Tao bang Users
Create table users 
(
	Users varchar(50),
	Passwords varchar(50)
)
insert into users (Users,Passwords)
values('Admin','Admin123')
-----------------------------------------Các module tạo dữ liệu dump cho các bảng trong cơ sở dữ liệu-------------------------------------------

-------------------------Bảng NCC----------------------
---SĐT----
create or alter proc spSDT(@sdt char(10) output)
as
begin
    declare @dauso char(3)=case abs(checksum(newid())) % 9	when 0 then '032'
															when 1 then '033'
															when 2 then '034'
															when 3 then '096'
															when 4 then '082'
															when 5 then '091'
															when 6 then '094'
															when 7 then '093'
															when 8 then '058'
						end
	declare @soduoi varchar(7), @i int=0	
	set @soduoi = right('0000000' + cast(abs(checksum(newid())) % 10000000 as varchar), 7);
	set @sdt = @dauso + @soduoi;
end
-----
create or alter proc spNCC
as
begin
    declare @dem1 int=1, @so char(10)
    declare @bang table (SĐT char(10));
    while @dem1 <= 1000
    begin
        declare @maNCC varchar(20)=right('00000' + cast(@dem1 as varchar), 5)
        declare @tenNCC varchar(50)='NCC' + cast(@dem1 as varchar)
        declare @dc varchar(50)='DC' + cast(@dem1 as varchar)
        declare @maNV varchar(20)='7'+right('0000' + cast(@dem1 as varchar), 4)
        declare @tenNV varchar(50)='Nv' + cast(@dem1 as varchar)

        declare @ktra bit=0 
        while @ktra=0
        begin
            exec spSDT @sdt=@so output
            if not exists (select 1 from @bang where SĐT = @so)  and not exists  (select 1 from NhaCungCap where SĐT = @so)
            begin
                insert into @bang (SĐT) values (@so)
                set @ktra=1
            end
        end
        if  @so is not null
        begin
            insert into NhaCungCap (MaNCC, TenNCC, DiaChi, SĐT, MaNV, TenNV)
            values (@maNCC, @tenNCC, @dc, @so, @maNV, @tenNV)
            set @dem1 = @dem1 + 1
        end
    end
end
exec spNCC
select *from NhaCungCap

------------------Bảng hàng-------------
---Đơn vị----
create or alter proc spDonvi @Donvi nvarchar(50) output
as
begin
	declare @donvi1 table (DV nvarchar(50))
	insert into @donvi1
	values (N'Cái'),(N'Hộp'),(N'Lít'),(N'Thùng')
	select @Donvi = (select top 1 DV from @donvi1 order by NEWID())
end
-------
create or alter proc SpHang
as
begin
    declare @dem2 int = 1
    while @dem2 <= 1000
    begin
		declare @MaHang varchar(20), @TenHang varchar(50), @DonGiaNhap numeric, @DonGiaBan numeric, @DonVi nvarchar(20)
		set @MaHang = '1' +right('0000' + cast( @dem2 as varchar), 4)
		set @TenHang = 'Hang' + cast(@dem2 as varchar)  
		set @DonGiaNhap = floor(rand() * 500000+10000)
		set @DonGiaBan = @DonGiaNhap  + floor(rand() * 100000 + 10000)
		exec [dbo].[spDonvi] @DonVi output
		if not exists (select 1 from Hang where MaHang = @MaHang)
        begin
            insert into Hang (MaHang, TenHang, DonGiaNhap, DonGiaBan, DonVi)
            values (@MaHang, @TenHang, @DonGiaNhap, @DonGiaBan, @DonVi);
        end 		
		set @dem2 = @dem2 + 1;
    end
end
exec SpHang
select * from Hang

----------------Bảng khách hàng--------------------
create or alter proc spKH
as
begin
    declare @i int=1, @so char(10)
    declare @bang table (SĐT char(10));
	while @i <= 1000
    begin
        declare @maKH char(15)='2'+right('00000000000000' + cast(@i as varchar), 14)
        declare @tenKH nvarchar(50)='KH' + cast(@i as varchar)

		declare @ktra bit=0 
        while @ktra=0
        begin
            exec spSDT @sdt=@so output
            if not exists (select 1 from @bang where SĐT = @so)  and not exists  (select 1 from KhachHang where SĐTKH=@so )
            begin
                insert into @bang (SĐT) values (@so)
                set @ktra=1
            end
        end
        if  @so is not null
        begin
            insert into KhachHang (MaKH, TenKH,SĐTKH)
            values (@maKH, @tenKH, @so)
            set @i= @i + 1
        end
	end
end
exec spKH
select *from KhachHang

-----------------Bảng HoaDonNo_NCC------------
create or alter proc sp_HoadonnoNCC
as
begin
	declare @z int=1
	while @z<=1000
	begin
		declare @MaNoNCC varchar(20)
		set @MaNoNCC='300000'+right('000'+cast(@z as varchar),4)
		set @z=@z+1
		insert into HoaDonNo_NCC(MaNoNCC,SoTienCL,SoTienDaTT)
		values (@MaNoNCC,0,0)
	end
end
exec sp_HoadonnoNCC
select * from HoaDonNo_NCC

----------------Bảng Nhập hàng-------------
--------Ngày giao-----
create or alter proc spngaygiao (@ngaygiao date output)
as
begin
    declare @nam table (Nam varchar(5))
    declare @ngay int, @thang int
	insert into @nam
    values ('2023'),('2022'),('2019'),('2020'),('2021')
    set @thang=cast(rand() *12+1 as int)
	set @ngay=cast(rand() * 28 + 1 as int)
    select @ngaygiao = cast((	select top 1 Nam 
								from @nam 
								order by newid()) + '-' + right('0'+cast(@thang as varchar),2)+'-'+right('0'+cast(@ngay as varchar),2) as date) 
end
------
create or alter proc spNhaphang
as
begin
declare @y int =1
while @y<=1000
begin
	declare @MaNhapHang varchar(20),@MaNCC varchar(20), @MaNoNCC VARCHAR(20), @Ngaygiao date 
	set @MaNhapHang=('5'+ right('000'+cast(@y as varchar),4))
	select top 1 @MaNCC=MaNCC from NhaCungCap order by newid()
	exec spngaygiao @Ngaygiao output
	select top 1 @MaNoNCC=MaNoNCC from HoaDonNo_NCC order by newid()
	if @MaNhapHang is not null and @MaNCC is not null and @MaNoNCC is not null and @Ngaygiao is not null
		begin
			if not exists (select 1 from NhapHang where MaNhapHang = @MaNhapHang)
				begin
					insert into NhapHang (MaNhapHang, MaNCC, MaNoNCC, KhuyenMai, TongTien, NgayGiao)
					values (@MaNhapHang, @MaNCC, @MaNoNCC, 0, 0, @Ngaygiao);
				end
			set @y=@y+1
		end
	end
end
exec spNhaphang
select * from NhapHang

----Hoadonkhno---
create or alter proc spHoadon_KHNo
as
begin
	declare @dem5 int = 1, @SoTienCL numeric, @SoTienDaTT numeric
	while @dem5 <= 1000
	begin
		declare @MaNoKH char(10) = '4' + right('00000000' + cast(@dem5 as varchar), 9)
		if NOT exists ( select 1 from Hoadon_KHNo where @MaNoKH = MaNoKH)
			begin 
				insert into Hoadon_KHNo(MaNoKH, SoTienCL, SoTienDaTT)
				values(@MaNoKH, 0, 0)
			end 
		set @dem5 = @dem5 + 1
	end
end
exec spHoadon_KHNo
select * from Hoadon_KHNo

-------------------Bảng Bán hàng ------------------
create or alter proc spBanHang
as
begin
	declare @i int=1, @KhuyenMai numeric, @TongTien	numeric
	while @i <= 1000
	begin
		declare	@MaBanHang	varchar(20) = '6' + right('0000' + cast(@i as varchar), 4)
		declare	@MaNoKH		varchar(20) select top 1 @MaNoKH=MaNoKH 
										from Hoadon_KHNo 
										order by NEWID()
		declare	@MaKH char(15)	select top 1 @MaKH=MaKH 
								from KhachHang 
								order by NEWID()
		declare @NgayBan date = dateadd(day, -abs(checksum(newid())) % 365, getdate())		
		insert into BanHang(MaBanHang, MaNoKH, MaKH, KhuyenMai, TongTien, NgayBan)
		values(@MaBanHang, @MaNoKH, @MaKH, 0, 0, @NgayBan)
		set @i = @i + 1 
	end	
end 
exec spBanHang 
select * from BanHang 

----------------Bảng banhangchitiet--------------
create or alter proc banhangchitiet
as 
begin
    declare @i int = 1 
    while @i <= 1000
    begin 
		declare @MaBanHang varchar(20), @MaHang varchar(20), @SoLuong int, @ThanhTien numeric, @DonGiaBan numeric,@Tongthanhtien numeric(18,2)=0
        select top 1 @MaBanHang = MaBanHang
        from BanHang
        where MaBanHang not in (select top (@i- 1) MaBanHang
								from BanHang
								order by MaBanHang)
        order by MaBanHang
		declare @q int=1
		declare @x int= cast(rand()*3+1 as int)
		while @q<=@x
		begin
			select top 1 @MaHang = MaHang from Hang order by newid()
			set @SoLuong = cast(rand() * 20+1 as int)
			select @DonGiaBan = DonGiaBan from Hang where MaHang = @MaHang 
			set @ThanhTien = @DonGiaBan * @SoLuong
			insert into BanHang_chitiet (MaBanHang, MaHang, SoLuong, ThanhTien)
			values (@MaBanHang, @MaHang, @SoLuong, @ThanhTien)
			set @Tongthanhtien=@Tongthanhtien+@ThanhTien
			set @q=@q+1
		end
		update BanHang  set TongTien=TongTien+@Tongthanhtien
		where MaBanHang=@MaBanHang 
        set @i = @i + 1
	end
end
exec banhangchitiet 
select * from BanHang_chitiet

----------------Bảng nhaphangchitiet-----------
create or alter proc nhaphangchitiet
as 
begin
    declare @i int = 1 

    while @i <= 1000
    begin 
		declare @MaNhapHang varchar(20), @MaHang varchar(20), @SoLuong int, @ThanhTien numeric, @DonGiaNhap numeric,@Tongthanhtien numeric(18,2)=0
        select top 1 @MaNhapHang = MaNhapHang
        from NhapHang
        where MaNhapHang not in (	select top (@i- 1) MaNhapHang
									from NhapHang
									order by MaNhapHang)
        order by MaNhapHang
		declare @q int=1
		declare @x int= cast(rand()*3+1 as int)
		while @q<=@x
		begin
			select top 1 @MaHang = MaHang from Hang order by newid()
			set @SoLuong = cast(rand() * 20+1 as int)
			select @DonGiaNhap = DonGiaNhap from Hang where MaHang = @MaHang 
			set @ThanhTien = @DonGiaNhap * @SoLuong
			insert into NhapHang_chitiet (MaNhapHang, MaHang, SoLuong, ThanhTien)
			values (@MaNhapHang, @MaHang, @SoLuong, @ThanhTien)
			set @Tongthanhtien=@Tongthanhtien+@ThanhTien
			set @q=@q+1
		end
		update NhapHang  set TongTien=TongTien+@Tongthanhtien
		where MaNhapHang=@MaNhapHang
        set @i = @i + 1
	end
end
exec nhaphangchitiet 
select * from NhapHang_chitiet

--------------------------------- 10 module trong cơ sở dữ liệu để phục vụ các thao tác xử lý dữ liệu-----------------------------------

/*Câu 1:Khi thêm một mặt hàng mới vào hệ thống, trước tiên cần kiểm tra rằng đơn giá nhập phải nhỏ hơn đơn giá bán và tên mặt hàng 
chưa tồn tại trong hệ thống. Nếu tên mặt hàng đã tồn tại hoặc điều kiện về đơn giá không thỏa mãn, thì thông báo “Không thỏa mãn” và dừng xử lý. 
Nếu các điều kiện này đều thỏa mãn, tiến hành thêm mới mặt hàng với mã hàng được tính bằng giá trị lớn nhất hiện có cộng thêm 1.
Sau đó, thông báo “Cập nhật thành công” và in ra tổng tiền của mặt hàng đó.*/

create or alter proc ThemSanPham @TenHang nvarchar(50),
								@DonGiaNhap float,
								@DonGiaBan float,
								@DonVi nvarchar(50),
								@ktr bit output
as
begin
	declare @MaHangNew varchar(20)
	if @DonGiaNhap >= @DonGiaBan or exists (select 1 from Hang where TenHang  = @TenHang)
	begin
		set @ktr=0
			print N'Không thoả mãn'
			return
	end
	select @MaHangNew = (max(MaHang) +1) from Hang;
	insert into Hang (MaHang, TenHang, DonGiaNhap, DonGiaBan, DonVi) 
	values (@MaHangNew, @TenHang, @DonGiaNhap, @DonGiaBan, @DonVi)
	set @ktr=1
	print N'Cập nhật thành công'
end
declare @ret bit
exec dbo.ThemSanPham 'Hang1009',  15000, 20000,N'Thùng',@ret output 
print(@ret)
select * from Hang

/* Câu 2: Kiểm tra định dạng số điện thoại của khách hàng. Nếu định dạng đúng thì thêm thông tin khách hàng, ngược lại thì kết thúc*/
create or alter proc themthongtinkhachhang(@SĐT char(10),@tenkh varchar(50),@ref bit output)
as
begin
	declare @i int=1
	if len(@SĐT)=10
	begin		
		while @i<=len(@SĐT)
		begin
			if SUBSTRING(@SĐT,@i,1) like '[0-9]' 
			begin
				set @i=@i+1
				set @ref=1
			end
			else 
				set @ref=0
				break
		end
	end
	else 
		set @ref=0
	if @ref=1 
	begin
		declare @makh varchar(20)
		set @makh=(select cast(cast(max(MaKH) as numeric(18)) +1 as varchar) from KhachHang)
		if not exists (select 1 from KhachHang where MaKH=@makh) and not exists (select 1 from KhachHang where SĐTKH=@SĐT) 
		begin
			insert into KhachHang(MaKH,TenKH,SĐTKH)
			values (@makh,@tenkh,@SĐT)
			set @ref=1
		end
		else 
			set @ref=0
	end
end
declare @b bit
exec themthongtinkhachhang '0344642480','nguyen van a',@b output
print(@b)

/*Câu 3:Tạo đơn hàng bán cho khách hàng với điều kiện số tiền nợ lại của khách hàng không bé hơn 2000000 theo số điện thoại. 
Nếu đủ điều kiện thì in ra tổng tiền đơn hàng và update tổng tiền vào bảng Bán hàng. Nếu vượt quá thì in ra thông báo 
'Không đủ điều kiện bán hàng' rồi huỷ đơn hàng đó*/
create or alter procedure taodonhang (@SĐT char(10),@mahoadon varchar(20) output,@ktr bit output)
as
begin
    declare @makh varchar(20),@sotiencl numeric,@manoKH varchar(20)
	if not EXISTS (SELECT 1 FROM KhachHang WHERE SĐTKH = @SĐT)
		begin 
			set @ktr=0
		end
	else 
	begin
		set @makh=(select MaKH from KhachHang where SĐTKH=@SĐT)
		select @sotiencl=sum(SoTienCL)
		from BanHang join BanHang_chitiet on BanHang.MaBanHang=BanHang_chitiet.MaBanHang
					join Hoadon_KHNo on BanHang.MaNoKH=Hoadon_KHNo.MaNoKH
		where MaKH=@makh

		if @sotiencl > 2000000 
		begin
			set @ktr=0
			return
		end
		else
		begin
			select @mahoadon = (max(MaBanHang) +1) from BanHang;
			select @manoKH = cast(cast(max(MaNoKH) as numeric(18)) +1 as varchar) from Hoadon_KHNo;
			if exists (select 1 from Hoadon_KHNo where MaNoKH = @manoKH)
				begin 
					set @ktr=0
				end
			else 
				begin 
					insert into Hoadon_KHNo(MaNoKH,SoTienCL,SoTienDaTT)
					values(@manoKH,0,0)
					if  exists (select 1 from BanHang where MaBanHang = @mahoadon) 
					begin
						set @ktr=0
					end
					else 
					begin
						insert into BanHang(MaBanHang, MaNoKH, MaKH, TongTien,NgayBan)
						values (@mahoadon, @manokh, @makh, 0,GETDATE())
						set @ktr=1
				end
			end
		end
	end
end
---
create type ItemTableType as table
							(
								mahang varchar(20),
								soluong int
							)
----
create or alter procedure taochitietdonhang (@ds ItemTableType readonly, @ref bit output)
as 
begin 
	declare @mahoadon varchar(20),@thanhtien numeric,@ktr bit
	exec taodonhang '0961107129',@mahoadon output,@ktr output
	if @ktr=0 
	begin 
		print N'không đủ điều kiện bán hàng'
		set @ref=0
	end
	else
	begin
		declare @dem int =1,@tongtien numeric=0
		if exists (select 1 from BanHang where MaBanHang = @mahoadon)
        BEGIN
			declare @mahang varchar(20),@soluong int
			declare cur cursor for
			select mahang, soluong from @ds
            open cur
            fetch next from cur into @mahang, @soluong
            while @@FETCH_STATUS = 0
			begin
				if not exists (select 1 from BanHang_chitiet where MaHang=@mahang and MaBanHang=@mahoadon)
				begin
					set @thanhtien=@soluong*(select DonGiaBan from Hang where MaHang=@mahang)		
					insert into BanHang_chitiet(MaBanHang,MaHang,SoLuong,ThanhTien)
					values (@mahoadon,@mahang,@soluong,@thanhtien)
					update BanHang set TongTien=TongTien+@thanhtien
					from BanHang join BanHang_chitiet on BanHang.MaBanHang=BanHang_chitiet.MaBanHang
					where BanHang_chitiet.MaBanHang=@mahoadon and MaHang=@mahang
			
					set @dem=@dem+1
				end
				fetch next from cur into @mahang, @soluong
			end
			close cur
			DEALLOCATE cur
			set @ref = 1
		end
		else 
			set @ref=0
	end
end
DECLARE @ret BIT
DECLARE @items ItemTableType
INSERT INTO @items VALUES ('10003', 2), ('10004', 3), ('10005', 1)
EXEC taochitietdonhang @ds=@items, @ref=@ret OUTPUT

/*Câu 4: Tính doanh thu/chi phí/ lợi nhuận của quán trong tháng 9 năm 2024 */
create or alter proc tinhtien @thoigian varchar(10),
							@doanhthu numeric output,
							@chiphi numeric output,
							@loinhuan numeric output

as
begin
	declare @thang int, @nam int
    if @thoigian like '%/%'
    begin
        set @thang = CAST(SUBSTRING(@thoigian, 1, CHARINDEX('/', @thoigian) - 1) AS INT);
        set @nam = CAST(RIGHT(@thoigian, 4) AS INT);
    end
    else if @thoigian like '%-%'
    begin
        set @thang = CAST(SUBSTRING(@thoigian, 1, CHARINDEX('-', @thoigian) - 1) AS INT);
        set @nam = CAST(RIGHT(@thoigian, 4) AS INT);
    end
    else if LEN(@thoigian) = 4 AND ISNUMERIC(@thoigian) = 1
    begin
        set @nam = CAST(@thoigian AS INT);
        set @thang = NULL;
    end
    else
    begin
        print (N'Định dạng không hợp lệ')
        return
    end
	select @doanhthu =sum(tongtien)
	from BanHang
	where year(NgayBan) = @nam and (month(NgayBan) = @thang or @thang is null)
	set @doanhthu=case when @doanhthu is null then 0
					else @doanhthu
				end		
	select @chiphi= sum(tongtien)
	from NhapHang
	WHERE YEAR(NgayGiao) = @nam AND (MONTH(NgayGiao) = @thang OR @thang IS NULL)
	set @chiphi=case when @chiphi is null then 0
					else @chiphi
				end		
    set @loinhuan = @doanhthu - @chiphi
end 
declare @a numeric, @b numeric , @c numeric
exec tinhtien '9/2024', @a output, @b output, @c output;
print @a
print @b
print @c

/*Câu 5: Xóa thông tin khách hàng  nếu thời gian mua hàng gần nhất (dưới 3 năm) và không còn nợ thì tiến hành xóa thông tin khách
hàng và các thông tin liên quan đến khách hàng đó*/
create or alter proc spDeleteKH(@MaKH varchar(20), @ret bit output)
as
begin
	declare @NgayBan date, @MaNoKH varchar(20), @SoTienCL numeric

	select top 1 @NgayBan = NgayBan 
	from BanHang
	where MaKH = @MaKH
	order by NgayBan desc

	if @NgayBan > dateadd(year, -3, getdate())
	begin
		set @ret = 0
		print @NgayBan
		return
	end

	else
	begin
		select @SoTienCL = sum(SoTienCL)
		from Hoadon_KHNo join BanHang on Hoadon_KHNo.MaNoKH = BanHang.MaNoKH
		where MaKH = @MaKH

		if @SoTienCL > 0
		begin
			set @ret = 0
			print @NgayBan
			return 
		end
		else
		begin
			delete from Hoadon_KHNo where MaNoKH in (select MaNoKH from BanHang where MaKH = @MaKH)
			if @@rowcount <= 0
			begin
				set @ret = 0
				print N'Lỗi khi xóa Hóa đơn nợ'
				return 
			end

			delete from KhachHang where MaKH = @MaKH
			if @@rowcount <= 0
			begin
				set @ret = 0
				print N'Lỗi khi xóa Khách hàng'
				return 
			end

			else
			begin
				set @ret = 1
			end
		end
	end
end
declare @a bit  
exec spDeleteKH '200000000000001' , @a output 
print @a

/*Câu 6: Cập nhật số tiền đã thanh toán và số tiền còn lại nếu khách hàng thanh toán hóa đơn nợ*/
create or alter proc spUpdateHoadon_KHNo(@ManoKH varchar(20), @SoTien numeric, @ret bit output)
as
begin
	declare @SoTienCL numeric
	select  @SoTienCL = SoTienCL
	from Hoadon_KHNo
	where MaNoKH=@ManoKH

	if @SoTien > @SoTienCL
	begin
		print N'Số tiền thanh toán vượt quá số tiền còn lại'
		set @ret = 0
		return
	end
	else
	begin
		update Hoadon_KHNo 
		set SoTienDaTT =SoTienDaTT + @SoTien,
			SoTienCL = SoTienCL - @SoTien
		where MaNoKH = @ManoKH
		set @ret=1
		if @@rowcount <= 0
		begin
			print N'lỗi update'
			set @ret = 0
		end
		else
		begin
			set @ret = 1
		end
	end
end
declare @a bit 
exec spUpdateHoadon_KHNo '200000000000001', 1, @a output
print @a 

/*Câu 7: Trước khi quyết định đặt hàng cần kiểm tra số lượng bán của từng sản phẩm muốn đặt theo MaHang trong 3 tháng vừa qua. 
Nếu số lượng <20  thì hiển thị thông báo “số lượng bán của sản phẩm này thấp hơn chỉ tiêu” và huỷ đặt mặt hàng đó.
Ngược lại, tiến hành đưa ra thông tin những nhà cung cấp có mặt hàng đó
*/
create or alter proc Kiemtra(@mahang varchar(20),@ref bit output )
as
begin
	declare @TongSL int
	if exists (select 1 from Hang where MaHang=@mahang)
	begin 
		set @TongSL=(  select SUM(SoLuong) 
					from BanHang join BanHang_chitiet on BanHang.MaBanHang=BanHang_chitiet.MaBanHang 
					where MaHang=@mahang and
					DATEDIFF(month,NgayBan,GETDATE())<=3)
		if @TongSL<20 
		begin
			print N'Số lượng bán của sản phẩm này thấp hơn chỉ tiêu'
			set @ref=0
		end
		else
		begin
			declare @ds table (mancc varchar(20), tenncc varchar(50), dc nvarchar(100),sdt char(10))
			insert into @ds select mancc=NhaCungCap.MaNCC, tenncc=TenNCC, dc=DiaChi, sdt=SĐT
							from NhaCungCap join NhapHang on NhaCungCap.MaNCC=NhapHang.MaNCC
											join NhapHang_chitiet on NhapHang.MaNhapHang=NhapHang_chitiet.MaNhapHang
							where MaHang=@mahang
			select *from @ds
			set @ref=1
		end
	end
	else 
		set @ref=0
end
declare @Ret bit
exec Kiemtra '10005',@Ret output
print(@Ret)

/*Câu 8:  Kiểm tra số tiền thanh toán cho nhà cung cấp có vượt quá số tiền còn lại hay không. Nếu có thì hiển thị thông báo 
'Số tiền vượt quá' và ngừng xử lý, ngược lại thì update số tiền đã thanh toán= số tiền đã thanh toán + số tiền vừa thanh toán 
và số tiền còn lại= Tổng tiền-số tiền đã thanh toán*/
create proc thanhtoantien ( @manoncc varchar(20),@sotientt numeric)
as
begin 
	declare @sotiencl numeric,@sotiendatt numeric,@tongtien numeric 
	select @sotiencl=SoTienCL,@tongtien=TongTien 
	from HoaDonNo_NCC join NhapHang on HoaDonNo_NCC.MaNoNCC=NhapHang.MaNoNCC
	where HoaDonNo_NCC.MaNoNCC=@manoncc
	if @sotientt>@sotiencl
	begin 
		print N'Số tiền vượt quá số tiền còn lại'
		print(@sotiencl)
	end
	else 
	begin
		update HoaDonNo_NCC 
		set SoTienDaTT=SoTienDaTT+@sotientt,
		SoTienCL=@tongtien-SoTienDaTT
		where MaNoNCC=@manoncc
		print N'cập nhật thành công'
	end
end
exec thanhtoantien '3000000001', '1000000'
/*Câu 9: Cập nhật lại thông tin nhà cung cấp khi có sự thay đổi về số điện thoại hoặc nhân viên giao hàng. */
create trigger CapNhatThongTin
on NhaCungCap
for update
as
begin
	declare @MaNCC varchar(20), @sdt char(10), @tennv nvarchar(50)
	select @MaNCC=MaNCC, @sdt=SĐT, @tennv=TenNV from inserted
	if not exists (select 1 from NhaCungCap where MaNCC=@MaNCC)	
		begin
			print N'Nhà cung cấp không tồn tại'
			rollback
		end
	else 
		if exists (select 1 from deleted where SĐT!=@sdt or TenNV!=@tennv)
			begin
				print N'Cập nhật thành công'
				update NhaCungCap 
				set SĐT=@sdt, TenNV=@tennv
				where MaNCC=@MaNCC
			end
		else
			begin
				print N'Không có sự thay đổi'
				rollback
			end
end
update NhaCungCap 
set SĐT='0948221751', TenNV=N'Nguyễn Văn A' 
where MaNCC='00001'
select *from NhaCungCap

/*Câu 10:  Khi áp dụng khuyến mãi cho một đơn hàng, kiểm tra các điều kiện sau: Nếu tổng giá trị của đơn hàng dưới 500000 thì không
áp dụng khuyến mãi và đưa ra thông báo 'Không đủ điều kiện áp dụng khuyến mãi', từ 500000-1000000 thì khuyến mãi 2%, còn trên 1000000 
thì khuyến mãi 5% và tiến hành cập nhật đơn hàng và đưa ra thông báo  'Cập nhật thành công đơn hàng'
*/
create trigger tinhkm
on BanHang
for insert
as
begin
    declare @MaBanHang varchar(20), @TongTien numeric(18,2), @KhuyenMai numeric(10,2)
    select @MaBanHang = MaBanHang, @TongTien = TongTien from inserted
    if @TongTien < 500000
    begin
		print N'Không đủ điều kiện áp dụng khuyến mãi'
        set @KhuyenMai = 0
    end
    else if @TongTien >= 500000 and @TongTien <= 1000000
    begin
        set @KhuyenMai = 0.02
    end
    else
    begin
        set  @KhuyenMai = 0.05
    end
    set @TongTien= @TongTien - (@TongTien * @KhuyenMai)
    update BanHang
    set KhuyenMai = @KhuyenMai*100, TongTien = @TongTien
    where MaBanHang = @MaBanHang
    print N'Cập nhật thành công đơn hàng'
end
insert into BanHang values ('61002', '4000000472', '200000000000864',0, 50000, GETDATE())
select *from BanHang


