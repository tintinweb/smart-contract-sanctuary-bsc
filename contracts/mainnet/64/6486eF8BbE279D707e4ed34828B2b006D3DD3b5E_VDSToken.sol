// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;

import "./IBEP20.sol";
import "./SafeMath.sol";

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract Ownable {
    address _owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract InviteReward {

    mapping (address => address) internal _refers;

    function _bindParent(address sender, address recipient) internal {
        if(_refers[recipient] == address(0)) {
            _refers[recipient] = sender;
        }
    }
    
    function getParent(address user) public view returns (address) {
        return _refers[user];
    }

}

contract LineReward {

    address[10] internal _lines;
    
    function _pushLine(address user) internal {
        for(uint256 i = _lines.length - 1; i > 0 ; i--) {
            _lines[i] = _lines[i-1];
        }
        _lines[0] = user;
    }

    function getLines() public view returns (address[10] memory) {
        return _lines;
    }

}

contract VDSToken is IBEP20, Ownable, LineReward, InviteReward {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string constant  _name = 'X-VDSToken';
    string constant _symbol = 'X-VDS';
    uint8 immutable _decimals = 8;
    uint256 private _totalSupply = 2100000000 * 1e8;
    
    bool private _hasLaunched = false;
    
    address public fundAddress;
    address public lpAddress;
    address public bonusAddress;
    address public lineAddress;
    
    address public pancakeAddress;
    
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBlacked;
    bool _isFine = false;

    uint32 public bonusIntervalTime = 86400;
    uint256 public bonusUsdtAmount = 200 * 1e18;
    uint256 public bonusLineUsdtAmount = 100 * 1e18;
    
    constructor()
    {
        _owner = msg.sender;
        
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
        
        setExcluded(_owner, true);
        
    }
    
    function launch() public onlyOwner {
        require(!_hasLaunched, "Already launched.");
        _hasLaunched = true;
    }

    function setLineAddress(address _lineAddress) public onlyOwner {
        lineAddress = _lineAddress;
        setExcluded(lineAddress, true);
    }

    function setBonusAddress(address _bonusAddress) public onlyOwner {
        bonusAddress = _bonusAddress;
        setExcluded(bonusAddress, true);
    }

    function setLpAddress(address _lpAddress) public onlyOwner {
        lpAddress = _lpAddress;
        setExcluded(lpAddress, true);
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
        setExcluded(fundAddress, true);
    }

    function setPancakeAddress(address _pancakeAddress) public onlyOwner {
        pancakeAddress = _pancakeAddress;
    }
    
    function setFine(bool isFine) public onlyOwner {
        _isFine = isFine;
    }

    function setBonusIntervalTime(uint32 _bonusIntervalTime) public onlyOwner {
        bonusIntervalTime = _bonusIntervalTime;
    }

    function setBonusUsdtAmount(uint256 _bonusUsdtAmount) public onlyOwner {
        bonusUsdtAmount = _bonusUsdtAmount;
    }

    function setBonusLineUsdtAmount(uint256 _bonusLineUsdtAmount) public onlyOwner {
        bonusLineUsdtAmount = _bonusLineUsdtAmount;
    }

    function setExcluded(address account, bool excluded) public onlyOwner {
        _isExcluded[account] = excluded;
    }
    
    function setBlacked(address account, bool blacked) public onlyOwner {
        _isBlacked[account] = blacked;
    }
    
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    
    function isBlacked(address account) public view returns (bool) {
        return _isBlacked[account];
    }
    
    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function burn(uint256 amount) public override returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
    function burnFrom(address account, uint256 amount) public override returns (bool) {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(sender != recipient 
            && sender != pancakeAddress && recipient != pancakeAddress
            ) {
            _bindParent(sender, recipient);
        }
        
        uint256 transferAmount = amount;
        
        if(!isExcluded(sender) && !isExcluded(recipient)) {
            
            require(!isBlacked(sender), "ERC20: blacked");

            if(sender == pancakeAddress || recipient == pancakeAddress) {
                require(_hasLaunched, "ERC20: has not launched");
            }

            if(sender != pancakeAddress && recipient != pancakeAddress) {
                uint256 tBurn = amount.div(1000).mul(20);
                _balances[address(0)] = _balances[address(0)].add(tBurn);
                transferAmount = transferAmount.sub(tBurn);
                _totalSupply = _totalSupply.sub(tBurn);
                emit Transfer(sender, address(0), tBurn);
            }

        }

        if(sender == pancakeAddress) {
            
            if(!isExcluded(recipient)) {

                _takeBonusAmount(sender, recipient, amount);
                _takeBonusLineAmount(sender, recipient, amount);
                
                uint256 onepercent = amount.mul(1).div(1000);
                if(onepercent > 0)
                {
                    
                    uint256 tInvite = _takeInviterFee(sender, recipient, amount);
                    uint256 tLine = _takeLineFee(sender, recipient, amount);
                    uint256 tLp = onepercent.mul(15);
                    
                    _balances[lpAddress] = _balances[lpAddress].add(tLp);

                    emit Transfer(sender, lpAddress, tLp);
                    
                    uint256 tFee = tInvite.add(tLine).add(tLp);
                    transferAmount = transferAmount.sub(tFee);

                    _pushLine(recipient);
                }
                
            }
            
        }
            
        if(recipient == pancakeAddress) {
            
            if(!isExcluded(sender)) {
                
                uint256 onepercent = amount.mul(1).div(1000);
                if(onepercent > 0)
                {
                    
                    uint256 tBonus = onepercent.mul(20);
                    uint256 tLp = onepercent.mul(30);
                    uint256 tLine = onepercent.mul(20);
                    uint256 tBurn = onepercent.mul(20);
                    
                    _balances[bonusAddress] = _balances[bonusAddress].add(tBonus);
                    _balances[lpAddress] = _balances[lpAddress].add(tLp);
                    _balances[lineAddress] = _balances[lineAddress].add(tLine);
                    _balances[address(0)] = _balances[address(0)].add(tBurn);

                    emit Transfer(sender, bonusAddress, tBonus);
                    emit Transfer(sender, lineAddress, tLine);
                    emit Transfer(sender, lpAddress, tLp);
                    emit Transfer(sender, address(0), tBurn);
                    
                    uint256 tFee = tBonus.add(tLine).add(tLp).add(tBurn);
                    transferAmount = transferAmount.sub(tFee);

                    if(_isFine) {
                        uint256 tFine = onepercent.mul(330);
                        _balances[address(0)] = _balances[address(0)].add(tFine);
                        transferAmount = transferAmount.sub(tFine);
                        _totalSupply = _totalSupply.sub(tFine);
                        emit Transfer(sender, address(0), tFine);
                    }

                }
                
            }
            
        }
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
    }
    
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    
    function _takeInviterFee(address sender, address recipient, uint256 amount) private returns (uint256) {

        if (recipient == pancakeAddress) {
            return 0;
        }

        address cur = recipient;
        address receiveD;

        uint256 totalFee = 0;
        uint8[5] memory rates = [20, 5, 5, 5, 5];
        for(uint8 i = 0; i < rates.length; i++) {
            cur = _refers[cur];
            if (cur == address(0)) {
                receiveD = fundAddress;
            }else{
				receiveD = cur;
			}
            uint8 rate = rates[i];
            uint256 curAmount = amount.div(1000).mul(rate);
            _balances[receiveD] = _balances[receiveD].add(curAmount);
            emit Transfer(sender, receiveD, curAmount);

            totalFee = totalFee + curAmount;

            if(receiveD == address(0)) {
                _totalSupply = _totalSupply.sub(curAmount);
            }
        }

        return totalFee;
    }

    function _takeLineFee(address sender, address recipient, uint256 amount) private returns (uint256) {

        if (recipient == pancakeAddress) {
            return 0;
        }

        address receiveD;

        uint256 totalFee = 0;
        uint8[6] memory rates = [3, 4, 5, 6, 7, 10];
        for(uint8 i = 0; i < rates.length; i++) {

            address cur = _lines[i];
            if (cur == address(0)) {
                receiveD = fundAddress;
            } else {
				receiveD = cur;
			}

            uint8 rate = rates[i];
            uint256 curAmount = amount.div(1000).mul(rate);
            _balances[receiveD] = _balances[receiveD].add(curAmount);
            emit Transfer(sender, receiveD, curAmount);

            totalFee = totalFee + curAmount;

            if(receiveD == address(0)) {
                _totalSupply = _totalSupply.sub(curAmount);
            }

        }
        return totalFee;
    }

    function _takeBonusAmount(address sender, address recipient, uint256 amount) private {

        if (sender != pancakeAddress && recipient == pancakeAddress) {
            return;
        }

        uint256 price = getExchangeCountOfOneUsdt();
        uint256 usdtAmount = price == 0 ? 0 : amount.mul(1e18).div(price);
        uint32 lastExchangeTime = getLastExchangeTime();
        if(block.timestamp >= lastExchangeTime + bonusIntervalTime && usdtAmount >= bonusUsdtAmount) {
            uint256 bounsAmount = _balances[bonusAddress];
            if(bounsAmount > 0) {
                _balances[bonusAddress] = _balances[bonusAddress].sub(bounsAmount);
                _balances[recipient] = _balances[recipient].add(bounsAmount);
                emit Transfer(bonusAddress, recipient, bounsAmount);
            }
        }

    }

    function _takeBonusLineAmount(address sender, address recipient, uint256 amount) private {

        if (sender != pancakeAddress && recipient == pancakeAddress) {
            return;
        }

        uint256 price = getExchangeCountOfOneUsdt();
        uint256 usdtAmount = price == 0 ? 0 : amount.mul(1e18).div(price);
        if(usdtAmount >= bonusLineUsdtAmount) {
            uint256 bounsAmount = _balances[lineAddress];
            if(bounsAmount > 0) {
                _balances[lineAddress] = _balances[lineAddress].sub(bounsAmount);
                _balances[recipient] = _balances[recipient].add(bounsAmount);
                emit Transfer(lineAddress, recipient, bounsAmount);
            }
        }

    }

    function getExchangeCountOfOneUsdt() public view returns (uint256)
    {
        if(pancakeAddress == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(pancakeAddress);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        if(pair.token0() == address(this))
        {
            a = _reserve0;
            b = _reserve1;
        }

        return a.mul(1e18).div(b);
    }

    function getLastExchangeTime() public view returns (uint32)
    {
        if(pancakeAddress == address(0)) {return uint32(block.timestamp % 2**32);}

        IPancakePair pair = IPancakePair(pancakeAddress);

        (, , uint32 timestamp) = pair.getReserves();

        return timestamp;
    }

}