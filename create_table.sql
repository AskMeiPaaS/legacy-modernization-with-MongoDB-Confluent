use kafka;

create table fin_account 
(
    account_id INTEGER NOT NULL, 
    district_id INTEGER NOT NULL, 
    create_date DATE NOT NULL, 
    frequency varchar(1) NOT NULL
);

create table fin_disp
(
    disp_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    disp_type VARCHAR(1) NOT NULL
);

create table fin_loan
(
    loan_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    granted_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    duration INTEGER NOT NULL,
    payments DECIMAL(12,2) NOT NULL,
    status VARCHAR(1) NOT NULL
);

create table fin_order
(
    order_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    bank_to VARCHAR(2) NOT NULL,
    account_to INTEGER NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    category VARCHAR(2) NOT NULL
);

create table fin_trans
(
    trans_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    trans_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    balance DECIMAL(12,2) NOT NULL,
    trans_type VARCHAR(1) NOT NULL,
    operation VARCHAR(3) NOT NULL,
    category VARCHAR(2) NOT NULL,
    other_bank_id VARCHAR(2) NOT NULL,
    other_account_id INTEGER NOT NULL 
);

insert into kafka.fin_account values 
(1,18,'2015-03-24','M'),
(2,1,'2013-02-26','M'),
(3,5,'2017-07-07','M'),
(4,12,'2016-02-21','M');

insert into kafka.fin_disp values
(1,1,1,'O'),
(2,2,2,'O'),
(3,3,2,'D'),
(4,4,3,'O'),
(5,5,3,'D');

insert into kafka.fin_loan values 
(4959,2,'2014-01-05',8095.20,24,337.30,'A'),
(4961,19,'2016-04-29',3027.60,12,252.30,'B'),
(4962,25,'2017-12-08',3027.60,12,252.30,'A'),
(4967,37,'2018-10-14',31848.00,60,530.80,'D'),
(4968,38,'2018-04-19',11073.60,48,230.70,'C');

insert into kafka.fin_order values 
(29401,1,'YZ',87144583,245.20,'HH'),
(29402,2,'ST',89597016,337.27,'LO'),
(29403,2,'QR',13943797,726.60,'HH'),
(29404,3,'WX',83084338,113.50,'HH'),
(29405,3,'CD',24485939,32.70,'  ');

insert into kafka.fin_trans values 
(5,1,'2015-04-13',367.90,467.90,'C','COB','  ','AB',41403269),
(6,1,'2015-05-13',367.90,2097.72,'C','COB','  ','AB',41403269),
(7,1,'2015-06-13',367.90,2683.52,'C','COB','  ','AB',41403269),
(8,1,'2015-07-13',367.90,3041.48,'C','COB','  ','AB',41403269),
(9,1,'2015-08-13',367.90,2890.27,'C','COB','  ','AB',41403269);

commit;