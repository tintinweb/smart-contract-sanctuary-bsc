/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity "0.8.11";

abstract contract IBEP20 {
    function totalSupply() public view virtual returns (uint256);

    function balanceOf(address tokenOwner)
        public
        view
        virtual
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        view
        virtual
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens)
        public
        virtual
        returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        virtual
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract TheBigToken is IBEP20, SafeMath {
    string public name = "TheBigToken";
    string public symbol = "BIG";
    uint8 public decimals = 18;
    uint256 public _totalSupply = 125000000000000 *10 **18; // 125 Trilhões de TheBigToken in supply
    address public STTO_wallet = 0x52d5E5380843EF5D644DcBEFD0579E317b65b68a;

    // An array of the verified charities
    address[] public charities = [0xaC9B745280F523e6cb4E952a4a0E511c19512214];

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    // Generate a random hash by using the next block's difficulty and timestamp
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            );
    }

    function _transfer(
        address from,
        address to,
        uint256 tokens
    ) private returns (bool success) {
        uint256 amountToBurn     = safeDiv(tokens, 4);    // 1% of the transaction shall be burned
        uint256 amountToHolder   = safeDiv(tokens, 12); // 3% of the transaction will be hold
        uint256 amountToDonate   = safeDiv(tokens, 8);  // 1,25% of the transaction shall be 5% of the transaction shall be donated
        uint256 amountToTransfer = safeSub(tokens, amountToBurn);

        address charity = charities[random() % charities.length]; // Pick a random charity

        balances[from] = safeSub(balances[from], tokens);
        balances[charity] = safeAdd(balances[charity], amountToDonate);

        balances[0x0000000000000000000000000000000000000000] = safeAdd(
            balances[0x0000000000000000000000000000000000000000],
            amountToBurn
        );

        balances[STTO_wallet] = safeAdd(balances[STTO_wallet], amountToHolder);
        balances[STTO_wallet] = safeAdd(balances[STTO_wallet], amountToBurn);

        balances[to] = safeAdd(balances[to], amountToTransfer);
        return true;
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        _transfer(msg.sender, to, tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        _transfer(from, to, tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}