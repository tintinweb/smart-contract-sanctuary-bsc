// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeTestRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract ChildCD3Fi is  Ownable {

    event TransferToParent(address parent, address token, uint value);    

    address private constant PancakeRouter = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0;    
    address busdToken = 0x91B0558556a2617F5eAc91a8f12C6641Baf95DB3;    
    address usdtToken = 0xe07346fcF970D6F573C3795a723a14710Acd762d;

    function transferBusdToParent(address _parent, address _token , uint _amount) external returns (uint) {
        require(
            msg.sender == _parent,
            "This function should be called from parent contract"
        );
        require(
            _amount <= IBEP20(address(_token)).balanceOf(address(this)),
            "Insufficient balance."
        );

        IBEP20(address(_token)).transfer(_parent, _amount);

        emit TransferToParent(_parent, _token, _amount);

        return _amount;
    }

    function _swapCD3FiForBusd(address _parent, address _CD3FiToken, uint256 sellAmount) external { 
        require(
            msg.sender == _parent,
            "This function should be called from parent contract"
        );       
        require(
            IBEP20(address(_CD3FiToken)).balanceOf(address(this)) >= sellAmount,
            "Insufficient CD3Fi balance"
        );
     
        IBEP20(address(_CD3FiToken)).approve(PancakeRouter, sellAmount);    
        
        address[] memory path = new address[](3);

        path[0] = address(this);
        path[1] = address(usdtToken);        
        path[2] = address(busdToken);

        IPancakeTestRouter(address(PancakeRouter)).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sellAmount,
            0,
            path,
            payable(msg.sender),
            block.timestamp + 36000
        );                       
    }
}