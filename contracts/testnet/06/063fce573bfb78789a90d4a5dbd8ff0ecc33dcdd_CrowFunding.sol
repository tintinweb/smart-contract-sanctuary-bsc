/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// 声明solidity版本为0.4.24
pragma solidity ^0.4.24;
// 创建合约CrowFunding
contract CrowFunding {
//定义众筹赞助方结构体
    struct Investor{
        address addr; //赞助地址
        uint count ;  //赞助数量
    }
//定义众筹发起方结构体 
    struct BySponsor{
        address addr;       //接收地址
        uint goalCount;     //众筹金额
        uint receiveCount;  //已经众筹到的金额
        uint investorNum;   //众筹次数
        mapping (uint =>Investor) investors; //用于保存多个众筹赞助方信息
    }
 
    uint bySponsorNum = 0 ;  //定义众筹发起方的ID号
    mapping (uint=>BySponsor) bySponsors; //定义映射用于保存多个合作发起方信息
 
//定义函数，用于生成众筹发起方对象
    function newBySponsor() payable {
        // 将合约发起方ID号增加1
        bySponsorNum++;
        /* 创建合约发起方对象
        众筹地址为:当前Accout地址
        众筹金额为:通过Value值设置
        */
        BySponsor memory bySponsor = BySponsor(msg.sender,msg.value,0,0);
        //将该众筹对象保存至映射bySponsors中
        bySponsors[bySponsorNum] = bySponsor;
 
    }
 /*定义函数，用于查看创建的众筹金额    
 传入参数: bySponsorId   众筹发起方ID
 返回值:   goalCount    创建的众筹金额 
 */
    function getGoalCount(uint bySponsorId) constant returns (uint){
         // 通过bySponsorId从映射bySponsors中取出对应的bySponsor对象
        BySponsor memory bySponsor = bySponsors[bySponsorId];
        //返回bySponsor对象的goalCount属性值
        return bySponsor.goalCount;
    }
 
 //定义函数，用于实现众筹赞助方的赞助功能，传入参数为众筹发起方ID号，并定义函数类型为payable
    function sponsor(uint bySponsorId)payable {
        // 通过bySponsorId从映射bySponsors中取出对应的bySponsor对象
        BySponsor storage bySponsor = bySponsors[bySponsorId];
        //设置合约代码可执行条件是赞助的金额必须>0
        require(msg.value >0);
        // 将赞助金额加入到bySponsor对象的receiveCount属性中
        bySponsor.receiveCount += msg.value;
        //众筹次数累加
        bySponsor.investorNum++;
        //将本次众筹赞助方信息保存至映射investors中
        bySponsor.investors[bySponsor.investorNum] = Investor(msg.sender,msg.value);
        //实现转账，从当前地址(众筹赞助方地址)转入bySponsor(众筹接收方地址)，金额为Value中定义的值
        bySponsor.addr.transfer(msg.value);
    }
 
 //定义函数，用于获取已经众筹到的金额，传入参数为众筹发起方ID号  
    function getReceiveCount(uint bySponsorId) constant returns (uint){
         // 通过bySponsorId从映射bySponsors中取出对应的bySponsor对象
        BySponsor memory bySponsor = bySponsors[bySponsorId];
        //返回bySponsor对象的receiveCount属性值
        return bySponsor.receiveCount;
    }    
//定义函数，用于检查是否众筹金额是否达标，传入参数为众筹发起方ID号 
    function checkComplete(uint bySponsorId) constant returns (bool){
         // 通过bySponsorId从映射bySponsors中取出对应的bySponsor对象
        BySponsor bySponsor = bySponsors[bySponsorId];
        // 判断设定的众筹金额是否有效(不为0)，并且已经众筹到的金额是否大于等于创建的众筹金额
        if (bySponsor.receiveCount >= bySponsor.goalCount && bySponsor.goalCount >0){
            return true;
        }else {
            return false;
        }
    }
}