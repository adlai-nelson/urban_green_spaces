-- Create tables containing parks and city polygon
--------------------------------------------
CREATE TABLE baltimore (
id SERIAL PRIMARY KEY,           -- set id paramaters
name VARCHAR(255),               -- set name paramaters
location GEOMETRY(polygon, 4326)  -- set geometry paramaters 
);

INSERT INTO baltimore (name, location)          -- identify columns to fill
SELECT	name, ST_Transform(way, 4326) as locn   -- fill colums,transform crs
FROM	planet_osm_polygon                      -- identify table to retreive data from
WHERE	boundary = 'administrative' and name = 'Baltimore';

CREATE TABLE green_spaces (
id SERIAL PRIMARY KEY,           -- set id paramaters
name VARCHAR(255),               -- set name paramaters
location GEOMETRY(polygon, 4326),  -- set geometry paramaters 
area_sq_m NUMERIC                -- Set paramaters for area column 
);

INSERT INTO green_spaces (name, location, area_sq_m)        -- identify columns to fill
SELECT	name, ST_Transform(way, 4326) as locn, ST_Area(way) -- fill colums, transform crs
FROM	planet_osm_polygon                                  -- identify table to retreive data from
WHERE	leisure	= 'park' and name is not null;              -- filter to parks with valid names
--------------------------------------------
-- Read data into QGIS and perform clip and dissolve functions - see analysis_report.docx
--------------------------------------------
-- Recalculate area for merged polygons (transforming to NAD 83 Maryland Stateplane so it calculates in sq m)
UPDATE "Parks" SET area_sq_m = ST_AREA(ST_Transform(geom, 6487))
--------------------------------------------
-- Do Analysis

SELECT COUNT(*) AS n_parks,           -- calculate number of parks
SUM(area_sq_m)/1e6 AS totalarea_sqkm, -- calculate total area in sq km
round(AVG(area_sq_m)) as avgarea_sqm, -- calculate mean area in sq m
round(max(area_sq_m)) as max_area,    -- display area of largest park
round (min(area_sq_m)) as min_area    -- display area of smallest park
FROM public."Parks";

select name, round(area_sq_m) as area
from "Parks"
order by area asc
limit 5;

select name, round((area_sq_m)) as area
from "Parks"
order by area desc
limit 5;

