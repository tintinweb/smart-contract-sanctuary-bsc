/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IERC20 {
     function approve(address spender, uint256 amount) external returns (bool);
     function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);
}

contract CodeOpen{

    address m_Owener;
    address m_TokenAddr;
    uint m_price = 0;    //token/bnb
    mapping( address => uint) m_TokenHodler;

    constructor ()  {
       m_Owener = msg.sender;
    }

    modifier IsOwener(){
        require(msg.sender == m_Owener);
        _;
    }

    function SetPrice(uint _price) IsOwener public {
        m_price = _price;
    }

    function BuyToken() public payable{
        require(msg.value>0);
        uint _tokenCount = msg.value*m_price;
        payable(m_Owener).transfer(msg.value);
        IERC20(m_TokenAddr).transferFrom(address(this), msg.sender, _tokenCount);
        //m_TokenHodler[msg.sender] = _tokenCount;
    }
    
    function GetCount() view public returns(uint){
        return m_TokenHodler[msg.sender];
    }

    function SetTokenAddr(address _tokenAddr) IsOwener public {
        require(_tokenAddr != address(0));
        m_TokenAddr = _tokenAddr;
    }

    function Approve() IsOwener public 
    {
        IERC20(m_TokenAddr).approve(address(this),196_000_000e18);
    }

}