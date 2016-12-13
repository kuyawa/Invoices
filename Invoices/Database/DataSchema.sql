Create Table if not exists 'Invoices' (
    invoiceId     integer not null primary key autoincrement,
    invoiceNumber text,
    issueDate     text default(datetime('now')),
    month         integer,
    year          integer,
    terms         text,
    dueDate       text default(datetime('now')),
    customerId    integer,
    customerName  text,
    billToName    text,
    billToLine1   text,
    billToLine2   text,
    billToCity    text,
    billToState   text,
    billToZip     text,
    billToCountry text,
    billToPhone   text,
    billToEmail   text,
    shipToName    text,
    shipToLine1   text,
    shipToLine2   text,
    shipToCity    text,
    shipToState   text,
    shipToZip     text,
    shipToCountry text,
    shipToPhone   text,
    shipToEmail   text,
    taxRate       real,
    totalSub      real,
    totalTax      real,
    totalShipping real,
    totalNet      real,
    status        integer,
    statusText    text,
    notes         text
);

--

Create Table if not exists 'InvoiceLines' (
    lineId        integer not null primary key autoincrement,
    invoiceId     integer not null,
    lineNumber    integer,
    quantity      integer,
    unitOfMeasure text,
    descript      text,
    annotation    text,
    unitPrice     real,
    amount        real,
    taxable       integer,
    taxRate       real,
    taxAmount     real,
    total         real
);

--

Create Table if not exists 'Customers' (
    customerId 	  integer not null primary key autoincrement,
    name          text,
    address1      text,
    address2      text,
    city          text,
    state         text,
    zip           text,
    country       text,
    phone         text,
    email         text
);

--

Create Table if not exists 'Sequences' (
    name          text not null primary key,
    start         integer not null,
    next          integer not null
);

--

Insert into Sequences(name, start, next) values('Invoices', 1, 1);
