/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

pragma solidity >=0.4.24;

contract Report{
  //定义一个合约，该合约具有合约地址，地址映射到学生的成绩单
    address Saddress;
    mapping(address=>Stu_report) stuRep;
    Stu_report sr;
        
    struct Stu_report{
      //定义学生成绩单结构体，存入课程列表，每个课程对应一个成绩的映射，len存储课程列表的长度
        bytes[] course;
        uint score;
        mapping(bytes=>uint) cs;
        uint len;
    }
    
    constructor(address stu_address) public {
      //构造函数，初始化地址
        Saddress = stu_address;
        sr = stuRep[Saddress];
        sr.len = 0;
    }
    
    function coursescore_add(string course, uint score) public {
      //课程和对应成绩的键值对增加
        bytes memory b = bytes(course);
        sr.course.push(b);
        sr.cs[b] = score;
        sr.len++;
    }
    
    function getcourseByIndex(uint index) public view returns(string){
      //根据索引值获取课程名
        if(index <= sr.len){
            return string(sr.course[index]);
        }else{
            return "0x";
        }
    }
    
    function getscoreBycourse(string course) public view returns(uint){
      //根据课程名获取对应成绩
        bytes memory b = bytes(course);
        return sr.cs[b];
    }
    
    function getcourseNo() public view returns(uint){
      //获取记录里的课程数
        return sr.len;
    }
    
    function del_course(uint index)public{
      //删除记录
        delete sr.cs[sr.course[index]];
        uint len = sr.len;
        if(index >= sr.len){
            return;
        }
        
        for(uint i=index; i < sr.len-1; i++){
            sr.course[i] = sr.course[i+1];
        }
        
        sr.len--;
        delete sr.course[len-1];
    }
    
    function mod_score(uint index, uint score)public{
      //记录修改
        if(index >= sr.len){
            return;
        }
        sr.cs[sr.course[index]] = score;
        
    }
}