import ballerina/http;
import ballerina/time;

type Employee record{|
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNo;
    string address;
    time:Date joinDate;
    time:Date contractEndDate;
|};

type NewEmp record{|
    string name;
    time:Date birthDate;
    string mobileNo;
    string address;
    time:Date joinDate;
    time:Date contractEndDate;
|};

type EmployeeNotFound record {|
    *http:BadRequest; // called as type inclusion
    ErrorDetails body;
|};

type ErrorDetails record {|
    string message;
    string details;
    time:Utc timeStamp;
|};

// table<Employee> key(id) employees = table [
//    {id:1, name:"Joe", birthDate: {year: 1990, month: 2, day: 3}, mobileNo: "0775544434",address: "", joinDate: {year: 0, month: 0, day: 0}}
// ];

table<Employee> key(id) employees = table[];

service /emp\-service on new http:Listener(9090) {
    // this resource can uniquely be identified and located using the url path /emp\-service
    // path is emp-service/employees
    // return all employees
    resource function get employees() returns Employee[]|error {
        return  employees.toArray(); // return in an array
    }

    // get employee by id
    resource function get employees/[int id]() returns Employee|EmployeeNotFound|error {
        Employee? employee = employees[id];

        if employee is () {
            EmployeeNotFound employeeNotFound = {
                body: {message: string `id: ${id}`, details: string `employee/${id}`, timeStamp: time:utcNow()}
            };
            return employeeNotFound;
        }

        return employee;
    }
    resource function post employees(NewEmp newEmp) returns http:Created|error {
        employees.add({id: employees.length() + 1, ...newEmp});
        return http:CREATED;
    }
}
