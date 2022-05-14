// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./ERC223/IERC223.sol";
import "./ERC223/IERC223Recipient.sol";

interface IContractReceiver {
    function tokenFallback(
        address _from,
        uint256 _value,
        bytes memory _data
    ) external;
}

contract DragonRose is IERC223 {
    string internal _name = "Dragon Rose";
    string internal _symbol = "DGR";
    uint8 internal _decimals = 18;
    uint256 private _totalSupply = (9 * 10000000 * 10) ^ 18; // 9 billion
    mapping(address => uint256) public balances; // List of user balances.
    mapping(address => mapping(address => uint256)) allowed;

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor() {}

    // Function to access name of token .
    function name() public view override returns (string memory) {
        return _name;
    }

    // Function to access symbol of token .
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    // Function to access decimals of token .
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    // Function to access total supply of tokens .
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return balances[who];
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function standard() public view override returns (string memory) {}

    //function that is called when transaction target is a contract
    function transferToContract(
        address _to,
        uint256 _value,
        bytes memory _data
    ) private returns (bool success) {
        require(balanceOf(msg.sender) < _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        IContractReceiver receiver = IContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint256 _value)
        private
        returns (bool success)
    {
        require(balanceOf(msg.sender) < _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transfer(address to, uint256 value)
        public
        override
        returns (bool success)
    {
        require(balanceOf(msg.sender) < value);
        bytes memory empty;
        if (isContract(to)) {
            return transferToContract(to, value, empty);
        }

        return transferToAddress(to, value);
    }

    function transfer(
        address to,
        uint256 value,
        bytes calldata data
    ) public override returns (bool success) {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            _to != address(0) &&
                _value > 0 &&
                balances[_from] >= _value &&
                allowed[_from][msg.sender] >= _value
        );

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

pragma solidity ^0.8.0;

 /**
 * @title Contract that will work with ERC223 tokens.
 */
 
abstract contract IERC223Recipient {


 struct ERC223TransferInfo
    {
        address token_contract;
        address sender;
        uint256 value;
        bytes   data;
    }
    
    ERC223TransferInfo private tkn;
    
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenReceived(address _from, uint _value, bytes memory _data) public virtual
    {
        /**
         * @dev Note that inside of the token transaction handler the actual sender of token transfer is accessible via the tkn.sender variable
         * (analogue of msg.sender for Ether transfers)
         * 
         * tkn.value - is the amount of transferred tokens
         * tkn.data  - is the "metadata" of token transfer
         * tkn.token_contract is most likely equal to msg.sender because the token contract typically invokes this function
        */
        tkn.token_contract = msg.sender;
        tkn.sender         = _from;
        tkn.value          = _value;
        tkn.data           = _data;
        
        // ACTUAL CODE
    }
}

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC223 standard token as defined in the EIP.
 */

abstract contract IERC223 {
    
    function name()        public view virtual returns (string memory);
    function symbol()      public view virtual returns (string memory);
    function standard()    public view virtual returns (string memory);
    function decimals()    public view virtual returns (uint8);
    function totalSupply() public view virtual returns (uint256);
    
    /**
     * @dev Returns the balance of the `who` address.
     */
    function balanceOf(address who) public virtual view returns (uint);
        
    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address
     * and returns `true` on success.
     */
    function transfer(address to, uint value) public virtual returns (bool success);
        
    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
     * and returns `true` on success.
     */
    function transfer(address to, uint value, bytes calldata data) public virtual returns (bool success);
     
     /**
     * @dev Event that is fired on successful transfer.
     */
    event Transfer(address indexed from, address indexed to, uint value);
    
     /**
     * @dev Additional event that is fired on successful transfer and logs transfer metadata,
     *      this event is implemented to keep Transfer event compatible with ERC20.
     */
    event TransferData(bytes data);
}