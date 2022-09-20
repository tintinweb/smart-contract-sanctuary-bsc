//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "contracts/interfaces/IBEP20.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "misterfocusth/BEP20-Token-Contract-Template/BEP20Token.sol";

// contract BEP20 is ERC20 {
//     constructor(uint initialSupply) ERC20("ARTHUR", "ART1") {
//         initialSupply = 1000000 * 10**18;
//         _mint(msg.sender, initialSupply);
//     }

//     mapping(address => uint256) public balances;

//     //Delegate transfer
//     mapping(address => mapping(address => uint256)) public allowed;

//     event Transfer(address _owner, uint256 _amount);

//     function balanceOfUser(address _user) public view returns (uint256) {
//         return balances[_user];
//     }

//     function mintToken() public {
//         require(
//             balances[msg.sender] <= 1000,
//             "You can't mint token because your balance is less than 1000"
//         );
//         balances[msg.sender] += 1000;

//         emit Transfer(msg.sender, 1000);
//     }

//     function _approve(address _receiver, uint256 _amount) public {
//         _amount = (_amount * 10) ^ 18;
//         allowed[msg.sender][_receiver] = _amount;
//     }

//     function transfer(address _receiver, uint256 _amount)
//         public
//         override
//         returns (bool)
//     {
//         _amount = (_amount * 10) ^ 18;
//         require(_amount == 0, "Amount of tokens can not be equal to zero");
//         require(
//             _amount < balances[msg.sender],
//             "You don't have enough tokens to send"
//         );

//         // _transfer(msg.sender, _receiver, _amount);
//         emit Transfer(_receiver, _amount);
//         emit Approval(msg.sender, _receiver, _amount);

//         balances[msg.sender] -= _amount;
//         balances[_receiver] += _amount;

//         return true;
//     }

//     function balanceOfReceiver(address _receiver)
//         public
//         view
//         returns (uint256)
//     {
//         return balances[_receiver];
//     }

//     function approve(address _delegate, uint256 _amount)
//         public
//         override
//         returns (bool)
//     {
//         _amount = (_amount * 10) ^ 18;
//         allowed[msg.sender][_delegate] = _amount;
//         return true;
//     }

//     function allowance(address _owner, address _delegate)
//         public
//         view
//         override
//         returns (uint256)
//     {
//         return allowed[_owner][_delegate];
//     }
// }
contract BEP20 is IBEP20 {
    string _name;
    string _symbol;
    uint8 _decimals;
    uint256 _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public owner;

    constructor() {
        owner = msg.sender;
        _name = "Arthur";
        _symbol = "ART3";
        _decimals = 18;
        _totalSupply;
        _mint(owner, _totalSupply);
        // emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner)
        public
        view
        virtual
        override
        onlyOwner
        returns (uint256 balance)
    {
        require(_owner == owner, "Only the owner can see their balance");
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        virtual
        override
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual override returns (bool success) {
        require(_allowances[_from][_to] > _value, "You must have at least 1");
        _transfer(_from, _to, _value);
        _allowances[_from][_to] += _value;
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        virtual
        override
        returns (bool success)
    {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function allowance(address _owner, address _spender)
        public
        view
        virtual
        override
        returns (uint256 _remaining)
    {
        return _allowances[_owner][_spender];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal virtual returns (bool success) {
        require(_from != address(0), "Cannot transfer from address 0");
        require(_balances[_from] > _value, "Value exceeds balance");
        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _mint(address account, uint256 amount) public virtual onlyOwner {
        require(account != address(0), "BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;

        emit Transfer(address(0), account, amount);
        _balances[account] += amount;

        _afterTokenTransfer(address(0), account, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 _remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}