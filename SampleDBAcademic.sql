--Sample PostgreSQL database of academic insitutions
--Created by "Binod Nepal"
--Email:binod@planetearthsolution.com
--Version:1.0
--License:PostgreSQL License(http://www.postgresql.org/about/licence)

-- From: http://binodsblog.blogspot.com/2011/02/academic-sample-database-for-postgresql.html


CREATE SCHEMA "Office";
CREATE SCHEMA "Academics";

CREATE TABLE "Office"."Registration"
(
  "OfficeId" SERIAL NOT NULL PRIMARY KEY,
  "OfficeCode" varchar(12) NOT NULL,
  "OfficeName" varchar(100) NOT NULL,
  CONSTRAINT "Unique_Registration_OfficeCode" UNIQUE ("OfficeCode"),
  CONSTRAINT "Unique_Registration_OfficeName" UNIQUE ("OfficeName")
);



CREATE TABLE "Office"."Departments"
(
  "DepartmentId" SERIAL NOT NULL PRIMARY KEY,
  "DepartmentCode" varchar(12) NOT NULL,
  "DepartmentName" varchar(50) NOT NULL,
  "Description" varchar(100) NULL,
  CONSTRAINT "Unique_Department_DepartmentCode" UNIQUE ("DepartmentCode"),
  CONSTRAINT "Unique_Department_DepartmentName" UNIQUE ("DepartmentName")
);


CREATE TABLE "Office"."BranchGroups"
(
  "BranchGroupId" SERIAL NOT NULL PRIMARY KEY,
  "BranchGroupCode" varchar(12) NOT NULL,
  "BranchGroupName" varchar(100) NOT NULL,
  "OfficeId" integer NOT NULL REFERENCES "Office"."Registration"("OfficeId"),
  "ParentBranchGroupId" integer NOT NULL REFERENCES "Office"."BranchGroups"("BranchGroupId"),
  CONSTRAINT "Unique_BranchGroups_BranchGroupCode" UNIQUE ("BranchGroupCode"),
  CONSTRAINT "Unique_BranchGroups_BranchGroupName" UNIQUE ("BranchGroupName")
);


CREATE TABLE "Office"."Branches"
(
  "BranchId" SERIAL NOT NULL PRIMARY KEY,
  "BranchGroupId" integer NOT NULL REFERENCES "Office"."BranchGroups"("BranchGroupId"),
  "BranchCode" varchar(12) NOT NULL,
  "BranchName" varchar(100) NOT NULL,
  "Address" varchar(100) NOT NULL,
  CONSTRAINT "Unique_Branches_BranchCode" UNIQUE ("BranchCode"),
  CONSTRAINT "Unique_Branches_BranchName" UNIQUE ("BranchName")
);


CREATE TABLE "Office"."Roles"
(
  "RoleId" SERIAL NOT NULL PRIMARY KEY,
  "RoleCode" varchar(12) NOT NULL,
  "RoleName" varchar(50) NOT NULL,
  "Description" varchar(100) NULL,
  CONSTRAINT "Unique_Roles_RoleCode" UNIQUE ("RoleCode"),
  CONSTRAINT "Unique_Roles_RoleName" UNIQUE ("RoleName")
);


CREATE TABLE "Office"."Users"
(
  "UserId" SERIAL NOT NULL PRIMARY KEY,
  "UserName" varchar(50),
  "DepartmentId" integer NOT NULL REFERENCES "Office"."Departments"("DepartmentId"),
  "RoleId" integer NOT NULL REFERENCES "Office"."Roles"("RoleId"),
  "Password" varchar(1000) NOT NULL,
  "IsLatent" boolean NOT NULL DEFAULT(false),
  CONSTRAINT "Unique_User_UserName" UNIQUE ("UserName")
);

CREATE TABLE "Academics"."Classes"
(
	"ClassId" SERIAL NOT NULL PRIMARY KEY,
	"ClassCode" varchar(12) NOT NULL,
	"ClassName" varchar(24) NOT NULL,
	CONSTRAINT "Unique_Academics_Classes_ClassCode" UNIQUE("ClassCode"),
	CONSTRAINT "Unique_Academics_Classes_ClassName" UNIQUE("ClassName")
);


CREATE TABLE "Academics"."ClassCapacity"
(
	"ClassCapacityId" SERIAL NOT NULL PRIMARY KEY,
	"ClassId" integer NOT NULL REFERENCES "Academics"."Classes"("ClassId"),
	"Capacity" integer NOT NULL,
	"UserId" integer NOT NULL REFERENCES "Office"."Users"("UserId"),
	"EntryDateTime" timestamp NOT NULL DEFAULT(now()),
	"Statuts" boolean NOT NULL DEFAULT(true)
);

CREATE TABLE "Academics"."Grades"
(
	"GradeId" SERIAL NOT NULL PRIMARY KEY,
	"GradeCode" varchar(12) NOT NULL,
	"GradeName" varchar(50) NOT NULL,
	"ParentGradeId" integer NULL REFERENCES "Academics"."Grades"("GradeId")
);

CREATE TABLE "Academics"."Programs"
(
	"ProgramId" SERIAL NOT NULL PRIMARY KEY,
	"ProgramCode" varchar(12) NOT NULL,
	"ProgramName" varchar(24) NOT NULL,
	"Description" varchar(100) NULL,
	CONSTRAINT "Unique_Academics_Programs_ProgramCode" UNIQUE("ProgramCode"),
	CONSTRAINT "Unique_Academics_Programs_ProgramName" UNIQUE("ProgramName")
);

CREATE TABLE "Academics"."Subjects"
(
	"SubjectId" SERIAL NOT NULL PRIMARY KEY,
	"SubjectCode" varchar(12) NOT NULL,
	"SubjectName" varchar(24) NOT NULL,
	"ParentSubjectId" integer NULL REFERENCES "Academics"."Subjects"("SubjectId"),
	CONSTRAINT "Unique_Academics_Subjects_SubjectCode" UNIQUE("SubjectCode"),
	CONSTRAINT "Unique_Academics_Subjects_SubjectName" UNIQUE("SubjectName")
);

CREATE TABLE "Academics"."Curriculums"
(
	"CurriculumId" SERIAL NOT NULL PRIMARY KEY,
	"CurriculumCode" varchar(12) NOT NULL,
	"CurriculumName" varchar(24) NOT NULL,
	"CurriculumStartDate" date NOT NULL,
	"CurriculumEndDate" date NOT NULL,
	"Status" boolean NOT NULL DEFAULT(true),
	CONSTRAINT "Unique_Curriculums_CurriculumCode" UNIQUE("CurriculumCode"),
	CONSTRAINT "Unique_Curriculums_CurriculumName" UNIQUE("CurriculumName"),
	CONSTRAINT "Check_Curriculums_Dates" CHECK("CurriculumStartDate" < "CurriculumEndDate")
);

CREATE TABLE "Academics"."ProgramDetails"
(
	"ProgramDetailId" SERIAL NOT NULL PRIMARY KEY,
	"ProgramId" integer NOT NULL REFERENCES "Academics"."Programs"("ProgramId"),
	"GradeId" integer NOT NULL REFERENCES "Academics"."Grades"("GradeId"),
	"SubjectId" integer NOT NULL REFERENCES "Academics"."Subjects"("SubjectId"),
	CONSTRAINT "Unique_Academics_ProgramDetails_ProgramGradeSubject" UNIQUE("ProgramId","GradeId","SubjectId")
 );



CREATE TABLE "Academics"."Books"
(
	"BookId" SERIAL NOT NULL PRIMARY KEY,
	"BookName" varchar(100) NOT NULL,
	"SubjectId" integer NOT NULL REFERENCES "Academics"."Subjects"("SubjectId"),
	"ISBN" bigint NULL,
	"Author" varchar(100) NULL,
	CONSTRAINT "Unique_Academics_Books_ISBN" UNIQUE("ISBN"),
	CONSTRAINT "Unique_Academics_Books_BookName" UNIQUE("BookName"),
	CONSTRAINT "Check_Academics_Books_ISBN" CHECK( ("ISBN" IS NULL) OR ("ISBN" <=9999999999999))
);


CREATE TABLE "Academics"."BookTypes"
(
	"BookTypeId" SERIAL NOT NULL PRIMARY KEY,
	"BookTypeCode" varchar(12) NOT NULL,
	"BookTypeName" varchar(50) NOT NULL,
	"Description" varchar(100) NULL,
	CONSTRAINT "Unique_Academics_BookTypes_BookTypeCode" UNIQUE("BookTypeCode"),
	CONSTRAINT "Unique_Academics_BookTypes_BookTypeName" UNIQUE("BookTypeName")	
);



CREATE TABLE "Academics"."CurriculumDetails"
(
	"CurriculumDetailId" BIGSERIAL NOT NULL PRIMARY KEY,
	"CurriculumId" integer NOT NULL REFERENCES "Academics"."Curriculums"("CurriculumId"),
	"GradeId" integer NOT NULL REFERENCES "Academics"."Grades"("GradeId"),
	"SubjectId" integer NOT NULL REFERENCES "Academics"."Subjects"("SubjectId"),
	"BookId" integer NOT NULL REFERENCES "Academics"."Books"("BookId"),
	"BookTypeId" integer NOT NULL REFERENCES "Academics"."BookTypes"("BookTypeId"),
	"UserId" integer NOT NULL REFERENCES "Office"."Users"("UserId"),
	"EntryDateTime" timestamp NOT NULL DEFAULT(now()),
	"Status" boolean NOT NULL DEFAULT(true),
	CONSTRAINT "Unique_Academics_CurriculumDetails_Misc" UNIQUE("CurriculumId","GradeId","SubjectId","BookId")
);

CREATE TABLE "Academics"."Syllabus"
(
	"SyllabusId" BIGSERIAL NOT NULL PRIMARY KEY,
	"SubjectId" integer NOT NULL REFERENCES "Academics"."Subjects"("SubjectId"),
	"Topic" varchar(50) NOT NULL,
	"Description" varchar(100) NULL,
	"SyllabusDuration" time NOT NULL,
	"Status" boolean NOT NULL DEFAULT(true)
);
