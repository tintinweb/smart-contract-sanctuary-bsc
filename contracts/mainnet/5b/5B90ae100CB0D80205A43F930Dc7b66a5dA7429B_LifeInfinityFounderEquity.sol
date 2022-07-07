pragma solidity ^0.5.17;

import "./StandardToken.sol";

contract UpgradeToken {
    function upBalance(address sender, uint256 balance) public{
        sender;
        balance;
    }
}

contract LifeInfinityFounderEquity is StandardToken, UpgradeToken {
    
    //upgrade
    //_balances
    //
    
    //for upgrade
    address[] public _historyRecords;
    mapping(address=>bool) private _records;

    constructor() public {
        _name = "Life Infinity Founder Equity";
        _symbol = "LIFE";
        _decimals = 18;

        _mint(address(this), 6680000000 ether);
        //_totalSupply = 6680000000 ether;
        //_balances[address(this)] = _totalSupply;

        _approve(address(this), msg.sender, _totalSupply);

        //emit Transfer(address(0), address(this), _totalSupply);
    }
            
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);
        if(!isRecordedOwner(to))
        {
            _historyRecords.push(to);
            _records[to] = true;
        }
    }

    function isRecordedOwner(address _owner) private view returns(bool) {
        bool rec = _records[_owner];
        return rec;
    }

    function burnFrom(address account, uint256 amount) public {
        uint256 _allowance = _allowances[account][msg.sender];
        require(_allowance >= amount, "LifeInfinityFounderEquity: transfer amount exceeds allowance...");
        _burnFrom(account, amount);
    }
        
    function upgrade(address newAddr, uint32 from, uint32 to) external onlyAdmin {
        for(uint32 index = from; index < _historyRecords.length && index <= to; index++)
        {
            address owner = _historyRecords[index];
            if(owner==address(this))
                continue;
            uint256 amount = _balances[owner];
            if(amount>0)
                UpgradeToken(newAddr).upBalance(owner, amount);
        }
    }
    
    function upBalance(address recipient, uint256 balance) public onlyAdmin{
        require(tx.origin == owner(), "LifeInfinityFounderEquity: only owner can upgrade!");
        uint256 amount = _balances[recipient];
        if(amount>0)
            return;
        _transferFrom(address(this), recipient, balance);
    }
        
}