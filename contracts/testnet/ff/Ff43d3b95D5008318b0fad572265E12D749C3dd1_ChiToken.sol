//SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address _to, uint256 _tokens)
        external
        returns (bool success);

    function allowance(address _tokenOwner, address _spender)
        external
        view
        returns (uint256 remaining);

    function approve(address _spender, uint256 _tokens)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract ChiToken is ERC20Interface {
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public override totalSupply;
    address public admin;
    address[] holders;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10**decimals;
        admin = msg.sender;
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can execute this");
        _;
    }

    function incrementSupply(uint256 _add_amount)
        public
        onlyAdmin
        returns (bool status)
    {
        balances[msg.sender] += _add_amount;
        totalSupply += _add_amount;
        return true;
    }

    function decrementSupply(uint256 _rest_amount)
        public
        onlyAdmin
        returns (bool status)
    {
        require(_rest_amount < totalSupply);
        balances[msg.sender] -= _rest_amount;
        totalSupply -= _rest_amount;
        return true;
    }

    function balanceOf(address _tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_tokenOwner];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokens
    ) internal {
        balances[_from] -= _tokens;
        balances[_to] += _tokens;

        bool isHolderExist;
        if (balances[_from] == 0) {
            for (uint256 i = 0; i < holders.length; i++) {
                if (holders[i] == _to) {
                    isHolderExist = true;
                }
                if (holders[i] == _from) {
                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                }
            }
        }
        if (!isHolderExist) {
            holders.push(_to);
        }
        emit Transfer(_from, _to, _tokens);
    }

    function transfer(address _to, uint256 _tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= _tokens, "insufficient balance");
        _transfer(msg.sender, _to, _tokens);
        return true;
    }

    function allowance(address _tokenOwner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_tokenOwner][_spender];
    }

    function approve(address _spender, uint256 _tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= _tokens);
        require(_tokens > 0);

        allowed[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) public override returns (bool success) {
        require(allowed[_from][msg.sender] >= _tokens, "not allowed");
        require(balances[_from] >= _tokens, "insufficient balance");

        allowed[_from][msg.sender] -= _tokens;
        _transfer(_from, _to, _tokens);

        emit Transfer(_from, _to, _tokens);

        return true;
    }

    function getHolders() public view returns (address[] memory) {
        return holders;
    }
}