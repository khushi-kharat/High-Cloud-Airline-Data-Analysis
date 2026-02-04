use highcloudairlines;
create table AircraftGroups(
         AircraftGroupID int,
         AircraftGroup text 
         );
select * from aircraftgroups;
create table AircraftTypes(
       AircraftTypeID int,
       AircraftType text
	);
select * from aircrafttypes;
create table Airlines(
      AirlineID int,
      Airline text
);
select * from airlines;
create table DistanceGroups(
       DistanceGroupID int,
       DistanceInterval text
);
select * from distancegroups;
create table CarrierGroups(
      CarrierGroupID int,
      CarrierGroup text
);
select * from carriergroups;
create table CarrierOperatingRegion(
        RegionCode varchar(50),
        CarrierOperatingRegion text
);
select * from carrieroperatingregion;
create table DestinationMarkets(
         DestinationAirportMarketID text,
         DestinationMarket text
);
select * from destinationmarkets;
delete from destinationmarkets order by DestinationAirportMarketID desc limit 1;
create table FlightTypes(
       DatasourceID text,
       FlightType text
);
select * from flighttypes;
create table OriginMarkets(
       OriginAirportMarketID text,
       OriginMarket text
);
select * from originmarkets;
delete from originmarkets order by OriginAirportMarketID desc limit 1;


## KPI-1 calcuate the fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields).
    set sql_safe_updates = 0;
    alter table maindata add column Date_Column date;
    update maindata set Date_Column = str_to_date(concat(Year,'-', Month, '-', Day), '%Y-%m-%d');
   create table calendar(
      DateField date,
      Year int,
      Month int,
      Day int,
      Week int,
      MonthName varchar(50),
      WeekDay int,
      YearMonth varchar(50),
      DayName varchar(50),
      Quarters varchar(50),
      Financial_Months varchar(50),
      Financial_Quarters varchar(50)
	);

insert into calendar (DateField , Year, Month, Day, Week, MonthName, WeekDay, YearMonth, DayName, Quarters, Financial_Months, Financial_Quarters)
select
     Date_Column as DateField,
     year(Date_Column) as Year,
     month(Date_Column) as Month,
     day(Date_Column) as Day,
     week(Date_Column) as Week,
     monthname(Date_Column) as MonthName,
     dayofweek(Date_Column) as WeekDay,
     concat(year(Date_Column), '-', monthname(Date_Column)) as YearMonth,
     dayname(Date_Column) as DayName,
case when monthname(Date_Column) in ('January', 'February', 'March') then 'Q1'
when monthname(Date_Column) in ('April', 'May', 'June') then 'Q2'
when monthname(Date_Column) in ('July', 'August', 'September') then 'Q3'
else 'Q4' end as Quarters,
case when monthname(Date_Column)='January' then 'FM10'
when monthname(Date_Column)='February' then 'FM11'
when monthname(Date_Column)='March' then 'FM12'
when monthname(Date_Column)='April' then 'FM1'
when monthname(Date_Column)='May' then 'FM2'
when monthname(Date_Column)='June' then 'FM3'
when monthname(Date_Column)='July' then 'FM4'
when monthname(Date_Column)='August' then 'FM5'
when monthname(Date_Column)='September' then 'FM6'
when monthname(Date_Column)='October' then 'FM7'
when monthname(Date_Column)='November' then 'FM8'
when monthname(Date_Column)='December' then 'FM9'
end  as Financial_Months,
case when monthname(Date_Column) in ('January', 'February', 'March') then 'FQ4'
when monthname(Date_Column) in ('April', 'May', 'June') then 'FQ1'
when monthname(Date_Column) in ('July', 'August', 'September') then 'FQ2'
else 'FQ3' end as Financial_Quarters
from
    maindata;
select * from calendar;


## KPI-2
## Year wise Load Factor Percentage.
select Year, 
round(avg(TransportedPassengers)/avg(AvailableSeats)*100,2) as Load_Factor_Percentage
from maindata group by Year;

## Quarterly wise Load Factor Percentage.
select Quarter,
round(avg(TransportedPassengers) / avg(AvailableSeats)*100,2) as Load_Factor_Percentage
from (select ceiling(Month / 3) as Quarter, TransportedPassengers, AvailableSeats
from maindata) as Quarterly
group by Quarter 
order by Quarter asc;

## Month Wise Load Factor Percentage.
select Month,
round(avg(TransportedPassengers) / avg(AvailableSeats)*100,2) as Load_Factor_Percentage
from maindata
group by Month
order by Month asc;

## KPI-3  Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats).
select CarrierName, ifnull((sum(TransportedPassengers) / nullif(sum(AvailableSeats), 0)) * 100,0) as Load_Factor_Percentage
from maindata
group by CarrierName
order by `Load_Factor_Percentage` desc;


## KPI-4 Identify Top 10 Carrier Names based passengers preference. 
select CarrierName, count(TransportedPassengers) as Total_Passengers
from maindata
group by CarrierName
order by Total_Passengers desc
limit 10;


## KPI-5 Display top Routes ( from-to City) based on Number of Flights .
select `From-ToCity` as Route, sum(DeparturesPerformed) as Number_of_Flights
from maindata
group by `From-ToCity`
order by Number_of_Flights desc
limit 10;


## KPI-6 Identify the how much load factor is occupied on Weekend vs Weekdays.
select 
case when DayName(Date_Column) in ('Saturday', 'Sunday') then 'Weekend' else 'Weekday'
end as Week_Type,
round(avg((TransportedPassengers / AvailableSeats)*100),2) as Load_Factor
from maindata
group by Week_Type; 


## KPI-7  Use the filter to provide a search capability to find the flights between Source Country, Source State, Source City to Destination Country , Destination State, Destination City
select CarrierName, OriginState, OriginCountry, DestinationCountry, DestinationState
from maindata
where OriginCountry = 'United States'
and OriginState = 'Alaska'
and DestinationCountry = 'United States'
and DestinationState = 'Texas';


## KPI-8 Identify number of flights based on Distance group.
select DistanceInterval, count(AirlineID) as Total_Flights
from maindata join distancegroups on maindata.DistanceGroupID = distancegroups.DistanceGroupID
group by DistanceInterval
order by Total_Flights desc;