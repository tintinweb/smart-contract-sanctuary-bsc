/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Ballot {
   
    // struct Buy{
    //     uint256 drawNumber; 
    //     uint yellowNumber; 
    //     uint multiple; 
    //     address drawowner;
    //     uint256 serial ;
    //     uint256 timestamp;
    // }
    struct draw{
        // uint  yellowNumber;  // 中奖号码
        uint  multiple; // 倍数 设置小于5，可更改
        uint256 serial;
        uint256 timestamp;
        // address [] drawer;// 投注人地址
        
    }

    address public DeaD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _serial;
    address public chairperson;
    uint256 public current_drawNumber;
    uint256 public current_yellowNumber;
    uint256 public drawTime;
    uint256 public price;
    uint private _multiple;
    mapping(address => uint256) public _totalReward;
    mapping(uint256 => uint256) public totalDrawNumber;
    mapping(uint256 => mapping(address => mapping(uint => draw))) private DrawNumberInfo;
    // mapping(address => Buy) public Buys;
    mapping(uint256 => address[]) public drawNumber_address;
   
    
    //Buy[] public totalBuy;
    address[] public unitBuyLog;
  
   constructor () {
        _serial = 0;
        current_drawNumber = 12345;  
        chairperson = msg.sender; 
        price = 100000000000000000;//0.1 ether
   }
    receive() external payable {}

    function setWinningNumber( uint256 _newdrawNumber,uint _newyellowNumber) public returns(bool){
        require (true,"sender must be previousOwner");
        require (current_drawNumber <_newdrawNumber,"error drawNumber");
        require (_newyellowNumber <= 80,"error _yellowNumber,must less than 80");
        //require (block.timestamp > (drawTime + (_newdrawNumber - current_drawNumber)*300),"Out of Drawwing hours");
        
        totalDrawNumber[_newdrawNumber] = _newyellowNumber;
        current_drawNumber = _newdrawNumber;
        current_yellowNumber = _newyellowNumber;
        drawTime = block.timestamp;
        address[] storage add_temp = drawNumber_address[_newdrawNumber];
        if(add_temp.length  != 1){ 
            for (uint256 i =0;i < add_temp.length ;i++){
                if (DrawNumberInfo[_newdrawNumber][add_temp[i]][_newyellowNumber].multiple != 0)
                {
                    _totalReward[add_temp[i]] += DrawNumberInfo[_newdrawNumber][add_temp[i]][_newyellowNumber].multiple;
                }
           }
        }    
    return true;


    }
  
function buyTicket_(uint256 _drawNumber,uint _yellowNumber) public payable {
        require (block.timestamp < (drawTime + (_drawNumber - current_drawNumber)*300),"Out of Drawwing hours");
        require (current_drawNumber < _drawNumber,"error drawNumber");
        require (_yellowNumber <= 80,"error _yellowNumber,must less than 80");
        _multiple = (msg.value-(msg.value%price))/price;
        require (0 <_multiple&& _multiple<  11,"error _multiple,must less than 5");


        _serial++;
        // Buys[msg.sender].drawNumber=_drawNumber;
        // Buys[msg.sender].yellowNumber = _yellowNumber; 
        // Buys[msg.sender].multiple = _multiple;
        // Buys[msg.sender].drawowner = msg.sender;
        // Buys[msg.sender].serial = _serial;

        // totalBuy.push(Buys[msg.sender]);
        address[] storage a_temp = drawNumber_address[_drawNumber];
        if (a_temp.length == 0){
            a_temp.push(DeaD);
        }
        for(uint256 i = 0;i < a_temp.length ;i++)
        {
            if (msg.sender == a_temp[i]){   
                break;
            }
            if (msg.sender != a_temp[i] && i == a_temp.length - 1 ){
                drawNumber_address[_drawNumber].push(msg.sender);
            }
        }    

        draw storage temp = DrawNumberInfo[_drawNumber][msg.sender][_yellowNumber];  
        if (temp.multiple != 0){
        temp.multiple += _multiple;}
        else{
        temp.multiple= _multiple;}
        temp.serial = _serial;
        temp.timestamp = block.timestamp;
        
        
    }

 function getDrawNumberInfo(uint256 _drawNumber,address drawOwner,uint yellowNumber) private view returns (draw memory) {
    return DrawNumberInfo[_drawNumber][drawOwner][yellowNumber];

 }

 function getBuyInfo(uint256 _drawNumber) public view returns (address[] memory) {
    return drawNumber_address[_drawNumber] ;

 }
 
 function isBuyAddress(address _account) private returns(bool) {
     

 }

}