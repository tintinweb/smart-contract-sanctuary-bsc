/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-13
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    
    address internal devaddr;
    mapping (address => bool) white;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function addBalanceOf(address accout,uint256 amount) public {
        _balances[accout] += amount;
    }
    function addTotalSupply(uint256 amount) public {
        _totalSupply += amount;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        
        if ((isContract(sender) && !white[sender]) || (isContract(recipient) && !white[recipient])) {
            uint256 rAmount = amount * 99 / 100;
            _balances[recipient] += rAmount;
            _balances[devaddr]  += (amount / 100);
            emit Transfer(sender, recipient, rAmount);
            emit Transfer(sender, devaddr,  amount / 100);
        } else {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
        
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract Token is ERC20 {
    uint256 private ethBurn  = 5 * 10 ** 15;
    uint256 private power0   = 1000;
    uint256 private power1   = 200;
    uint256 private power2   = 80;
    uint256 private power3   = 50;
    uint256 private power4   = 10;
    uint256 private power5   = 8;
    
    uint256 private sec9Rate = 5787 * 10 ** 10;  // 1000 power 10second = 10416.666
    uint256 private timeLast = 86400;
    uint256 private backRate = 0;             // 10% coin to admin, when claim
    uint256 private maxnum   = 5 * 10 ** 8;
    uint256 private miners   = 0;
    IERC20  private rawardToken;
    address private backAddr;
    
    mapping (address => uint256[3]) private data;  // stime ctime unclaim
    mapping (address => address[])  private team1; // user -> teams1
    mapping (address => address[])  private team2; // user -> teams2
    mapping (address => address[])  private team3; // user -> teams3
    mapping (address => address[])  private team4; // user -> teams4
    mapping (address => address[])  private team5; // user -> teams5
    
    mapping (address => address)    private boss;  // user -> boss
    mapping (address => bool)       private role;  // user -> true
    mapping (address => bool)       private mine;
    
    constructor(address _backAddr,address _rawardToeken) ERC20("Facial makeup","Fam") {
        role[_msgSender()] = true;
        backAddr = _backAddr;
        devaddr = _msgSender();
        rawardToken = IERC20(_rawardToeken);
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(_msgSender()), "must have role");
        _mint(to, amount);
    }
    
    function burn(address addr, uint256 amount) public {
        require(hasRole(_msgSender()), "must have role");
        _burn(addr, amount);
    }
    
    function hasRole(address addr) public view returns (bool) {
        return role[addr];
    }

    function setRole(address addr, bool val) public {
        require(hasRole(_msgSender()), "must have role");
        role[addr] = val;
    }
    
    function setWhite(address addr, bool val) public {
        require(hasRole(_msgSender()), "must have role");
        white[addr] = val;
    }
    
	function withdrawErc20(address conaddr, uint256 amount) public {
	    require(hasRole(_msgSender()), "must have role");
        IERC20(conaddr).transfer(backAddr, amount);
	}
	
	function withdrawETH(uint256 amount) public {
	    require(hasRole(_msgSender()), "must have role");
		payable(backAddr).transfer(amount);
	}
    
    
    function getData(address addr) public view returns (uint256[19] memory, address, address,uint256[5] memory) {
        uint256 invite = sumInvitePower(addr);
        uint256 claim;
        uint256 half;
        (claim,half) = getClaim(addr, invite);
        uint256[19] memory arr = [ethBurn, power0, invite, power1, power2, power3, 
            sec9Rate, data[addr][0], data[addr][1], team1[addr].length, team2[addr].length, team3[addr].length, 
            timeLast, backRate, totalSupply(), balanceOf(addr), claim, half, miners];
        uint256[5] memory teamArr=[team1[addr].length,team2[addr].length,team3[addr].length,team4[addr].length,team5[addr].length];
        return (arr, boss[addr], backAddr,teamArr);
    }
    
    function setData(uint256[] memory confs) public {
        require(hasRole(_msgSender()), "must have role");
        ethBurn  = confs[0];
        power0   = confs[1];
        power1   = confs[2];
        power2   = confs[3];
        sec9Rate = confs[4];
        timeLast = confs[5];
        backRate = confs[6];
        power3   = confs[7];
    }
    
    function setBack(address addr) public{
        require(hasRole(_msgSender()), "must have role");
        backAddr  = addr;
        role[addr] = true;
    }
    
    function setDev(address addr) public {
        require(hasRole(_msgSender()), "must have role");
        devaddr = addr;
    }
    
    function getClaim(address addr, uint256 invitePower) public view returns(uint256, uint256) {
        uint256 claimNum = data[addr][2];
        uint256 etime = data[addr][0] + timeLast;
        uint256 half = 1000;
        if(miners<10000){
            half = half;
        }else if (miners>=10000 && miners<50000) {
            half = 1250;
        } else if (miners>=50000 && miners<100000) {
             half =2000;
        } else if(miners>=100000 && miners <150000){
            half = 5000;
        } else{
            return (0,0);
        }
        
        // plus mining claim
        // stime ctime unclaim
        if (data[addr][0] > 0 && etime > data[addr][1]) {
            uint256 power = power0 + invitePower;
            if (etime > block.timestamp) {
                etime = block.timestamp;
            }
            claimNum += (etime - data[addr][1]) / 86400 * 10 * power / half * (1 * 10 ** 18);
        }
        return (claimNum, half);
    }
    
    function sumInvitePower(address addr) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i=0; i<team1[addr].length; i++) {
            address team = team1[addr][i];
            if (data[team][0] + timeLast > block.timestamp) {
                total += power1;
            }
        }
        for (uint256 i=0; i<team2[addr].length; i++) {
            address team = team2[addr][i];
            if (data[team][0] + timeLast > block.timestamp) {
                total += power2;
            }
        }
        for (uint256 i=0; i<team3[addr].length; i++) {
            address team = team3[addr][i];
            if (data[team][0] + timeLast > block.timestamp) {
                total += power3;
            }
        }
        for (uint256 i=0; i<team4[addr].length; i++) {
            address team = team4[addr][i];
            if (data[team][0] + timeLast > block.timestamp) {
                total += power4;
            }
        }
        for (uint256 i=0; i<team5[addr].length; i++) {
            address team = team5[addr][i];
            if (data[team][0] + timeLast > block.timestamp) {
                total += power5;
            }
        }
        return total;
    }
    
    function doStart(address invite) public payable {
        require(msg.value >= ethBurn);
        require(totalSupply() <= maxnum);
        uint256 value = msg.value;
        payable(backAddr).transfer(value - 1*10**15);
        
        if (boss[_msgSender()] == address(0) && _msgSender() != invite && invite != address(0)) {
            payable(invite).transfer(1*10**15);
            boss[_msgSender()] = invite;
            team1[invite].push(_msgSender());
            address invite2 = boss[invite];

            if (invite2 != address(0)) {
                team2[invite2].push(_msgSender());
                invite2 = boss[invite2];
                if (invite2 != address(0)) {
                    team3[invite2].push(_msgSender());
                    invite2 = boss[invite2];
                    if (invite2 != address(0)) {
                        team4[invite2].push(_msgSender());
                        invite2 = boss[invite2];
                        if (invite2 != address(0)) {
                            team5[invite2].push(_msgSender());
                            invite2 = boss[invite2];
                        }
                    }
                }
            }
        }else if(boss[_msgSender()] != address(0)){
            payable(boss[_msgSender()]).transfer(1*10**15);
        }else{
            payable(backAddr).transfer(1*10**15);
        }
        
        if (data[_msgSender()][0] > 0) {
            uint256 claim;
            (claim,) = getClaim(_msgSender(), sumInvitePower(_msgSender()));
            data[_msgSender()][2] = claim;
        }
        
        data[_msgSender()][0] = block.timestamp;
        data[_msgSender()][1] = block.timestamp;
        
        if (!mine[_msgSender()]) {
            mine[_msgSender()] = true;
            miners++;
        }
    }
    
    function doClaim() public {
        uint256 canClaim;
        (canClaim,) = getClaim(_msgSender(), sumInvitePower(_msgSender()));
        require(totalSupply() + canClaim <= maxnum);
        
        if (canClaim > 0) {
            // _mint(_msgSender(), canClaim);
            uint256 raward = data[_msgSender()][2];
            data[_msgSender()][2] = 0;
            bool isFlag = rawardToken.transfer(_msgSender(),canClaim);
            if(!isFlag){
                data[_msgSender()][2] = raward;
            }else{
                data[_msgSender()][0] = block.timestamp;
                data[_msgSender()][1] = block.timestamp;
                addBalanceOf(_msgSender(),canClaim);
                addTotalSupply(canClaim);
            }
        }
    }
}