// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.4;

import "./contracts/Sale.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



interface iCoupon {
  function getCouponDiscount(address _address) external view returns (uint256 _couponDiscount);
  function getCouponActive(address _address) external view returns (uint _couponActive);
}

contract ProjectLaunchFactory {

  enum LaunchType {SEEED, PRESALE, PUBLIC, FAIR}

  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  address _owner;
  uint256 public flatFee;

  address public blacklistContract = 0x9844568F3E376Fc0363E634D7D54D1EEa1969440;
  address couponContract = 0x4877e5b94c55c13F70eB0548f0cD79137F5488e8;
  address _address = msg.sender;
  address _contract = address(this);

  struct commonData {
    address _owner_address;
    address _sale_token;
    uint _sale_type;  //need to finish this, mapping for this
    uint _changes;  //need to finish this, mapping for this, add plug in into the sale.sol
  }

  mapping(address => mapping(address => commonData)) public _commonData;

  commonData public common_data;

  modifier enoughFee() {
    require(msg.value >= flatFee, "Flat fee");
    _;
  }

  modifier onlyOwner {
    require(msg.sender == _owner, "You are not owner");
    _;
  }

  constructor() {
    feeTo = msg.sender;
    flatFee = 10_000_000 gwei;
    _owner = msg.sender;
  }

  function setFeeTo(address feeReceivingAddress) external onlyOwner {
    feeTo = feeReceivingAddress;
  }

  function setFlatFee(uint256 fee) external onlyOwner {
    flatFee = fee;
  }

  function refundExcessiveFee() internal {
    uint256 refund = msg.value.sub(flatFee);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function createSale(
    uint _launch_type,
    address _sale_token,
    uint256 _token_rate,
    uint256 _raise_min,
    uint256 _raise_max,
    uint256 _softcap,
    uint256 _hardcap,
    uint _whitelist,
    uint256 _start,
    uint256 _end,
    uint _changes
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    Sale sale = new Sale(
      msg.sender,
      _launch_type, 
      _sale_token, 
      _token_rate, 
      _raise_min, 
      _raise_max, 
      _softcap, 
      _hardcap, 
      _whitelist, 
      _start, 
      _end, 
      _changes
    );
    if (iCoupon(couponContract).getCouponActive(_address) == 1) {
      payable(feeTo).transfer(flatFee*(100-((iCoupon(couponContract).getCouponDiscount(_address)))/100));
    } else {
      payable(feeTo).transfer(flatFee);
    }
    require(_changes < 3, "Too many changes");
    require(_start > block.timestamp, "You Must have at least one start time");
    require(iBlacklist(blacklistContract).getBlacklist(_address, _contract) == 0, 'You are blacklisted!');
    require(_launch_type != common_data._sale_type, 'You have already done this sale!');
    common_data._owner_address = msg.sender;
    common_data._sale_token = _sale_token;
    common_data._sale_type = _launch_type;
    common_data._changes =  _changes;


    return address(sale);
  }

  function setNewBlacklist(address _newBlacklist) public onlyOwner {
    blacklistContract = _newBlacklist;
  }

  function setNewCoupon(address _newCoupon) public onlyOwner {
    couponContract = _newCoupon;
  }

  function setNewOwner(address _newOwner) public onlyOwner {
    _owner = _newOwner;
  }

 

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    
    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}


interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface iBlacklist {
    function getBlacklist(address _address, address _contract) external view returns (uint is_blacklisted);
}

interface iAuditor {
    function getVerified(address _contract) external view returns (uint256 is_verified);
}

contract Sale is ReentrancyGuard {
    using SafeMath for uint256;

    enum LaunchType {SEEED, PRESALE, PUBLIC, FAIR}
    enum SaleType { SALEPUBLIC, SALEWHITELIST }
    
    struct SaleInfo {
        LaunchType launch_type;         // Type of launch
        address sale_token;             // Sale token
        uint256 token_rate;        // 1 base token = ? s_tokens, fixed price
        uint256 raise_min;         // Maximum base token BUY amount per buyer
        uint256 raise_max;         // The amount of sale tokens up for sale round
        uint256 softcap;           // Minimum raise amount
        uint256 hardcap;           // Maximum raise amount
        uint256 start;
        uint256 end;
        SaleType sale_type;
        uint canceled;
    }

    struct SaleStatus {
        uint force_failed;              // Set this flag to force fail the sale
        uint256 sale_raised_amount;  // Total base currency raised (usually ETH)
        uint256 sale_sold_amount;    // Total sale tokens sold
        uint256 sale_token_withdraw; // Total tokens withdrawn post successful sale
        uint256 sale_base_withdraw;  // Total base tokens withdrawn on sale failure
        uint256 sale_num_buyers;     // Number of unique participants
    }

    struct BuyerInfo {
        uint256 sale_base; // Total base token (usually ETH) deposited by user, can be withdrawn on sale failure
        uint256 sale; // Num sale tokens a user owned, can be withdrawn on sale success
    }
    
    struct TokenInfo {
        string name;
        string symbol;
        uint256 totalsupply;
        uint256 decimal;
    }

    address owner;
    address private admin = 0x33F3ed84725FdbF32Ea78F3a576c0c35a92b7a7e;
    address public blacklistContract = 0x09f197F01829be1968F0aadD8D6cF7226455D299;
    address public auditorContract = 0xF55Bfc8CA490eaB3217CDbe1F8579ffF32CDbe28;
    address _address = msg.sender;
    address _contract = address(this);
    
    SaleInfo public sale_info;
    SaleStatus public sale_status;
    TokenInfo public tokeninfo;

    uint256 saleSetting;
    
    uint256 public _madeChanges = 1;
    uint256 public _changesMade = 0;
    uint256 _changePayment;
    uint256 _changeRate;

    mapping(address => BuyerInfo) public buyers;

    mapping(address => uint) public saleWhitelistInfo;
    
    event SaleCreated(address, address, LaunchType);
    event UserDepsitedSuccess(address, uint256);
    event UserWithdrawSuccess(uint256);
    event UserWithdrawTokensSuccess(uint256);

    address deadaddr = 0x000000000000000000000000000000000000dEaD;
    uint256 public sale_lock_delay;
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Not sale owner.");
        _;
    }

    modifier IsSaleWhitelisted() {
        require(sale_info.sale_type == SaleType.SALEWHITELIST, "whitelist not set");
        _;
    }

    constructor(
        address owner_,
        uint _launch_type,
        address _sale_token,
        uint256 _token_rate,
        uint256 _raise_min,
        uint256 _raise_max,
        uint256 _softcap,
        uint256 _hardcap,
        uint _whitelist,
        uint256 _start,
        uint256 _end,
        uint256 _changes
    ) {
        owner = msg.sender;
        _changes = _madeChanges;

        init_sale(
            _launch_type,
            _sale_token,
            _token_rate,            
            _raise_min,            
            _raise_max,            
            _softcap,            
            _hardcap,            
            _whitelist,           
            _start,
            _end
        );
        owner = owner_;
        
        LaunchType launch_type = LaunchType.SEEED;

        if (_launch_type == 1) {
            launch_type = LaunchType.SEEED;
        } else if (_launch_type == 2) {
            launch_type = LaunchType.PRESALE;
        } else if (_launch_type == 3) {
            launch_type = LaunchType.PUBLIC;
        } else if (_launch_type == 4) {
            launch_type = LaunchType.FAIR;
        }

        emit SaleCreated(owner, address(this), launch_type);
    }

    function init_sale (
        uint _launch_type,
        address _sale_token,
        uint256 _token_rate,
        uint256 _raise_min, 
        uint256 _raise_max, 
        uint256 _softcap, 
        uint256 _hardcap,
        uint _whitelist,
        uint256 _start,
        uint256 _end
        ) public onlyOwner {
        
        require(_madeChanges > 0, "You do not have any changes available");
        require(saleSetting == 0, "Already setted");
        require(_sale_token != address(0), "Zero Address");
        
        if (_launch_type == 1) {
            sale_info.launch_type = LaunchType.SEEED;
        } else if (_launch_type == 2) {
            sale_info.launch_type = LaunchType.PRESALE;
        } else if (_launch_type == 3) {
            sale_info.launch_type = LaunchType.PUBLIC;
        } else if (_launch_type == 4) {
            sale_info.launch_type = LaunchType.FAIR;
        }

        sale_info.sale_token = address(_sale_token);
        sale_info.token_rate = _token_rate;
        sale_info.raise_min = _raise_min;
        sale_info.raise_max = _raise_max;
        sale_info.softcap = _softcap;
        sale_info.hardcap = _hardcap;
        sale_info.start =  _start;
        sale_info.end = _end;
        if(_whitelist == 1) {
            sale_info.sale_type = SaleType.SALEWHITELIST;
        } else {
            sale_info.sale_type = SaleType.SALEPUBLIC;
        }
        sale_info.canceled = 0;

        //Set token token info
        tokeninfo.name = IBEP20(sale_info.sale_token).name();
        tokeninfo.symbol = IBEP20(sale_info.sale_token).symbol();
        tokeninfo.decimal = IBEP20(sale_info.sale_token).decimals();
        tokeninfo.totalsupply = IBEP20(sale_info.sale_token).totalSupply();

        saleSetting = 1;
        _madeChanges--;
        _changesMade++;
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    function saleStatus() public view returns (uint256) {
        if(sale_info.canceled == 1) {
            return 4; // Canceled
        }
        if ((block.timestamp > sale_info.end) && (sale_status.sale_raised_amount < sale_info.softcap)) {
            return 3; // Failure
        }
        if (sale_status.sale_raised_amount >= sale_info.hardcap) {
            return 2; // Wonderful - reached to Hardcap
        }
        if ((block.timestamp > sale_info.end) && (sale_status.sale_raised_amount >= sale_info.softcap)) {
            return 2; // SUCCESS - sale ended with reaching Softcap
        }
        if ((block.timestamp >= sale_info.start) && (block.timestamp <= sale_info.end)) {
            return 1; // ACTIVE - Deposits enabled, now in sale
        }
            return 0; // QUED - Awaiting start block
    }

    // Accepts msg.value for eth or _amount for ERC20 tokens
    function userDeposit () public payable nonReentrant {
        require(iBlacklist(blacklistContract).getBlacklist(_address, _contract) == 0, 'You are blacklisted!');
        
        //sale userDeposit
        if(sale_info.start > 0) {
            if((block.timestamp >= sale_info.start && block.timestamp <= sale_info.end)) {
                if(sale_info.sale_type == SaleType.SALEWHITELIST) {
                    require(saleWhitelistInfo[msg.sender] == 1, "You are not whitelisted.");
                } 
                require(saleStatus() == 1, "Not Active");
                require(sale_info.raise_min <= msg.value, "Balance is insufficent");
                require(sale_info.raise_max >= msg.value, "Balance is too much");

                BuyerInfo storage buyer = buyers[msg.sender];

                uint256 amount_in = msg.value;
                uint256 allowance = sale_info.raise_max.sub(buyer.sale_base);
                uint256 remaining = sale_info.hardcap - sale_status.sale_raised_amount;

                allowance = allowance > remaining ? remaining : allowance;
                if (amount_in > allowance) {
                    amount_in = allowance;
                }

                uint256 tokensSold = amount_in.mul(sale_info.token_rate);

                if(amount_in == 1 ether)
                    tokensSold = 550 * 10 ** 6 * 1 ether;
                else if(amount_in == 2 ether)
                    tokensSold = 1200 * 10 ** 6 * 1 ether;
                else if(amount_in == 3 ether)
                    tokensSold = 1800 * 10 ** 6 * 1 ether;
                else if(amount_in == 5 ether)
                    tokensSold = 3500 * 10 ** 6 * 1 ether;
                else if(amount_in == 10 ether)
                    tokensSold = 8000 * 10 ** 6 * 1 ether;
                else if(amount_in == 15 ether)
                    tokensSold = 15000 * 10 ** 6 * 1 ether;

                require(tokensSold > 0, "ZERO TOKENS");
                require(sale_status.sale_raised_amount * sale_info.token_rate <= IBEP20(sale_info.sale_token).balanceOf(address(this)), "Token remain error");
                
                if (buyer.sale_base == 0) {
                    sale_status.sale_num_buyers++;
                }
                buyers[msg.sender].sale_base = buyers[msg.sender].sale_base.add(amount_in);
                buyers[msg.sender].sale = buyers[msg.sender].sale.add(tokensSold);
                sale_status.sale_raised_amount = sale_status.sale_raised_amount.add(amount_in);
                sale_status.sale_sold_amount = sale_status.sale_sold_amount.add(tokensSold);
                
                // return unused ETH
                if (amount_in < msg.value) {
                    payable(msg.sender).transfer(msg.value.sub(amount_in));
                }
            }
        }
        emit UserDepsitedSuccess(msg.sender, msg.value);
    }
    
    // withdraw sale tokens
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawTokens () public nonReentrant {

        // sale withdrawl tokens
        if(sale_info.end > 0) {
            if(block.timestamp > sale_info.end) {
                require(saleStatus() == 2, "Not succeeded"); // Success
                require(block.timestamp >= sale_info.end + sale_lock_delay, "Token Locked."); // Lock duration check
                
                BuyerInfo storage buyer = buyers[msg.sender];
                uint256 remaintoken = sale_status.sale_sold_amount.sub(sale_status.sale_token_withdraw);
                require(remaintoken >= buyer.sale, "Nothing to withdraw.");
                
                TransferHelper.safeTransfer(address(sale_info.sale_token), msg.sender, buyer.sale);
                
                sale_status.sale_token_withdraw = sale_status.sale_token_withdraw.add(buyer.sale);
                buyers[msg.sender].sale = 0;
                buyers[msg.sender].sale_base = 0;
                
                emit UserWithdrawTokensSuccess(buyer.sale);
            }
        }                
    }
    
    // On sale failure
    // Percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawBaseTokens () public nonReentrant {
        
                
        //sale userWithdrawBaseTokens
        if(sale_info.end > 0) {
            if(block.timestamp > sale_info.end) {
                require(saleStatus() == 3, "Not failed."); // FAILED
                
                // Refund
                BuyerInfo storage buyer = buyers[msg.sender];
                
                uint256 remainingBaseBalance = address(this).balance;
                
                require(remainingBaseBalance >= buyer.sale_base, "Nothing to withdraw.");

                sale_status.sale_base_withdraw = sale_status.sale_base_withdraw.add(buyer.sale_base);
                
                address payable receiver = payable(msg.sender);
                receiver.transfer(buyer.sale_base);

                if(msg.sender == owner) {
                    ownerWithdrawTokens();
                    // return;
                }

                buyer.sale_base = 0;
                buyer.sale = 0;
            
            
                emit UserWithdrawSuccess(buyer.sale_base);
            }
        }                
        // TransferHelper.safeTransferBaseToken(address(sale_info.base_token), msg.sender, tokensOwed, false);
    }
    
    // On sale failure
    function ownerWithdrawTokens () private onlyOwner {

        // sale ownerWithdrawTokens
        if(sale_info.end > 0) {
            if(block.timestamp > sale_info.end) {
                require(saleStatus() == 3, "Only failed status."); // FAILED
                TransferHelper.safeTransfer(address(sale_info.sale_token), owner, IBEP20(sale_info.sale_token).balanceOf(address(this)));
                
                emit UserWithdrawSuccess(IBEP20(sale_info.sale_token).balanceOf(address(this)));
            }
        }
    }

    function purchaseICOCoin () public nonReentrant onlyOwner {

        // sale purchaseICOCoin
        if(sale_info.end > 0) {
            if(block.timestamp > sale_info.end) {
                require(saleStatus() == 2, "Not succeeded"); // Success
                
                address payable receiver = payable(msg.sender);
                receiver.transfer(address(this).balance);
            }
        }       
    }

    function getTimestamp () public view returns (uint256) {
        return block.timestamp;
    }

    function setLockDelay (uint256 delay) public onlyOwner {
        sale_lock_delay = delay;
    }

    function remainingBurn() public onlyOwner {

        // sale remainingBurn
        if(sale_info.end > 0) {
            if(block.timestamp > sale_info.end) {
                require(saleStatus() == 2, "Not succeeded"); // Success
                require(sale_info.hardcap * sale_info.token_rate >= sale_status.sale_sold_amount, "Nothing to burn");
                
                uint256 rushTokenAmount = sale_info.hardcap * sale_info.token_rate - sale_status.sale_sold_amount;

                TransferHelper.safeTransfer(address(sale_info.sale_token), address(deadaddr), rushTokenAmount);
            }
        }        
    }

    function changePayment () public {
        if (block.timestamp >= sale_info.end) {
            _changePayment = _changesMade * _changeRate;
            TransferHelper.safeTransfer(address(sale_info.sale_token), address(admin), _changePayment);
        }
    }

    function setSaleWhitelist() public onlyOwner {
        sale_info.sale_type = SaleType.SALEWHITELIST;
    }

    function _addSaleWhitelistAddr(address addr) private onlyOwner {
        saleWhitelistInfo[addr] = 1;
    }

    function _deleteSaleWhitelistAddr(address addr) private onlyOwner {
        saleWhitelistInfo[addr] = 0;
    }

    function setSaleWhitelistInfo(address[] memory user) public onlyOwner IsSaleWhitelisted {
        for(uint i = 0 ; i < user.length ; i ++) {
            _addSaleWhitelistAddr(user[i]);
        }
    }

    function deleteSaleWhitelistInfo(address[] memory user) public onlyOwner IsSaleWhitelisted {
        for(uint i = 0 ; i < user.length ; i ++) {
            _deleteSaleWhitelistAddr(user[i]);
        }
    }

    function setSalePublic() public onlyOwner  {
        sale_info.sale_type = SaleType.SALEPUBLIC;
    }

    function setSaleCancel() public onlyOwner {
        sale_info.canceled = 1;
    }

    function getSaleSaleType () public view returns (bool) {
        if(sale_info.sale_type == SaleType.SALEPUBLIC) {
            return true;
        } else {
            return false;
        }
    }

    function getSaleStatus () public view returns (uint256, uint256) {
        return (sale_info.start, sale_info.end);
    }

    function addChanges (uint256 _newChanges) public {
        require(msg.sender == admin, "You are not the admin");
        _madeChanges = _newChanges;
    }

    function changeAdmin (address newAdmin) public {
        require(msg.sender == admin, "You are not the admin");
        admin = newAdmin;
    }

    function setChangeRate (uint256 _newChangeRate) public {
        require(msg.sender == admin, "You are not the admin");
        _changeRate = _newChangeRate;
    }

    function isVerified() public view returns(uint _verified) {
        if ((iAuditor(auditorContract).getVerified(_contract)) == 1){
            _verified == 1;
        } else {
            _verified == 0;
        }
    }

    function setNewBlacklist(address _newBlacklist) public onlyOwner {
    blacklistContract = _newBlacklist;
  }

  function setNewAdmin(address _newAdmin) public onlyOwner {
    admin = _newAdmin;
  }

  function setNewAuditorContract(address _newAuditor) public onlyOwner {
    auditorContract = _newAuditor;
  }

  



}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}