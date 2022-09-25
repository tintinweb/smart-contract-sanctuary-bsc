/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

pragma solidity ^0.8.0;

contract SchoolManagerment {
    address public admin;

    uint public countStudent = 0;
    
    // enum Grade {Primary1, Primary2, Primary3, Primary4, Primary5, Primary6,
    //             Secondary1, Secondary2, Secondary3,
    //             High1, High2, High3}

    enum Subject {Vietnamese, Math, English}
    
    struct Student {
        string fullName;        
        uint age;
        string sex;
        uint grade;
        bool isStudying;
        mapping(Subject => uint) score;
    }


    mapping(uint => Student) public StudentsMap;
    // mapping(string => uint) public Grades;
    // mapping(string => uint) public Subjects;

      constructor() {
        // Subjects["TIENGVIET"] = 0;
        // Subjects["VIETNAMESE"] = 0;
        // Subjects["tiengviet"] = 0;

        admin = msg.sender;        
    }

    function addStudent(string memory fullName, uint age, string memory sex, uint grade) public {
        Student storage newStudent = StudentsMap[countStudent];
        // StudentsMap[countStudent] = Student(fullName, age, sex, grade, true);
        newStudent.fullName = fullName;
        newStudent.age = age;
        newStudent.sex = sex;
        newStudent.grade = grade;
        newStudent.isStudying = true;
        newStudent.score[Subject.Vietnamese] = 0;
        newStudent.score[Subject.Math] = 0;
        newStudent.score[Subject.English] = 0;
        countStudent += 1;
    }

    function getStudentScores(uint studentID) public view returns (uint _Vietnamese, uint _Math, uint _English) {
        _Vietnamese = StudentsMap[studentID].score[Subject.Vietnamese];
        _Math = StudentsMap[studentID].score[Subject.Math];
        _English = StudentsMap[studentID].score[Subject.English];
    }

    function setScore(uint studentID, Subject subjectID, uint newScore) public {
        Student storage student = StudentsMap[studentID];
        student.score[subjectID] = newScore;
    }

    // function testDiv() public view returns (uint256) {
    //     uint apy = 24;
    //     uint256 amount = 1000000000000000000000;
    //     uint durationDay = SafeMath.div(200000,86400);
    //     uint256 profitPerYear = SafeMath.div(amount*apy, 100);
    //     uint256 profitPerDay = SafeMath.div(profitPerYear, 365);
    //     return durationDay*profitPerDay;
    // }

}