/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface IERC20 {    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

library Address {    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

abstract contract Ownable is Context {
    address internal _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }    
    function owner() public view virtual returns (address) {
        return _owner;
    }    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = time;
        emit OwnershipTransferred(_owner, address(0));
    }
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock.");
        require(block.timestamp > _lockTime , "Contract is locked.");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view virtual override returns (string memory) {
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(to != address(0), "ERC20: transfer to the zero addy");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero addy");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero addy");
        require(spender != address(0), "ERC20: approve to the zero addy");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

interface VRFCoordinatorV2Interface {
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);
  function createSubscription() external returns (uint64 subId);
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;
  function addConsumer(uint64 subId, address consumer) external;
  function removeConsumer(uint64 subId, address consumer) external;
  function cancelSubscription(uint64 subId, address to) external;
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

contract test is ERC20Burnable, Ownable, ReentrancyGuard, VRFConsumerBaseV2 {

    // Chainlink VRF variables
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE; //0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04; //0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92;
    uint32 callbackGasLimit = 6000000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  3;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;


    using SafeMath for uint256;

    IUniswapV2Router02 public immutable v2Router;
    address public immutable v2Pair;
    uint256 private constant maxUint256 = ~uint256(0);
    uint256 private tax = 5;
    bool private taxOn = true;
    bool private growPot = true;
    bool private inSwap;
    address[] private sellPath = new address[](2);
    address private routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;        
    mapping (address => bool) private excluded;
    uint256 public activeRound;

    struct user {
        uint256 tokens;
        string lottoTicket;
        bool exists;
    }

    struct lottoTicket {
        string lottoTicket;
        address user;
        uint256 round;
        uint256 created;
        bool winner;
        uint256 tokens;
        uint256 ethWon;
    }

    string public winningLottoTicket1;
    string public winningLottoTicket2;
    string public winningLottoTicket3;

    lottoTicket[] public lottoTickets;
    lottoTicket[] public lottoTicketWinners;

    struct round {
        uint256 eth;
        uint256 totalAmt;
        uint256 expire;  
        uint256 userCount;  
        bool launched;
        mapping(address => user) users;
    }

    mapping (uint256 => round) public rounds;
    mapping (address => uint256) public lastUserBlock;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public roundDuration = 10 minutes; //4 hours;
    uint256 public launchTime;

    constructor() ERC20("TEST", "TEST", 18) VRFConsumerBaseV2(vrfCoordinator)  {      

        IUniswapV2Router02 _v2Router = IUniswapV2Router02(routerAddress);
        v2Router = _v2Router;
        v2Pair = IUniswapV2Factory(_v2Router.factory()).createPair(address(this), _v2Router.WETH());

        _approve(msg.sender, routerAddress, maxUint256);
        _approve(address(this), routerAddress, maxUint256);
        sellPath[0] = address(this);
        sellPath[1] = v2Router.WETH();
        _mint(msg.sender, 1e27);

        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = 415; //312;
    }

    function _transfer(address from, address to, uint256 amount) internal override  {       

        // Buy
        if (taxOn && 
            from == v2Pair &&  
            !excluded[to] &&           
            to != owner() && 
            to != address(0) &&
            to != address(0xdead)) {

            uint256 lottoTax = amount.mul(tax).div(100);
            super._transfer(from, to, amount.sub(lottoTax));

            if (lottoTax > 0) {
                require(lastUserBlock[_msgSender()] != block.number, "Cannot have multiple buys on same block");
                super._transfer(from, address(this), lottoTax);    

                // Launch Lottery on first buy.  Will execute once.
                if (!rounds[0].launched) {
                    rounds[0].launched = true;
                    rounds[0].expire = block.timestamp + roundDuration;
                    launchTime = block.timestamp;
                    activeRound = 0;
                }     

                string memory generatedLottoTicket;
                generatedLottoTicket = toHex(keccak256(abi.encodePacked(_msgSender(), block.timestamp)));
                rounds[activeRound].totalAmt = rounds[activeRound].totalAmt + lottoTax;

                // Create lotto ticket
                lottoTicket memory _lottoTicket;
                _lottoTicket.lottoTicket = generatedLottoTicket;
                _lottoTicket.round = activeRound;
                _lottoTicket.created = block.timestamp;
                _lottoTicket.user = _msgSender();
                _lottoTicket.winner = false;
                _lottoTicket.tokens = amount;
                lottoTickets.push(_lottoTicket);

                lastUserBlock[_msgSender()] = block.number;

                // Complete Round and Declare Winners
                if (rounds[activeRound].expire < block.timestamp && rounds[activeRound].eth > 0)
                {
                    PayTheWinners();
                }

            }            
        }
        else {
            super._transfer(from, to, amount);            
        }

        
    }

    function PayTheWinners() public onlyOwner {
        // Call Chainlink Verifiable Randomness Function generator. https://vrf.chain.link
        // Callback function fulfillRandomWords() will choose winners and pay out ETH.
        requestRandomWords();
    }

    /* 
        Anyone can call this function to grow the Pot.   Gas costs apply of course.
    */
    function growThePot() nonReentrant isHuman public {

        uint256 roundTokens = rounds[activeRound].totalAmt;

        _approve(msg.sender, routerAddress, roundTokens);
        _approve(address(this), msg.sender, roundTokens);

        IUniswapV2Pair pair = IUniswapV2Pair(v2Pair);
        pair.sync();       

        require(roundTokens > 0, "Nothing to Swap");

        if (roundTokens > 0 && growPot) {            
            uint256 beforeEth = address(this).balance;
            v2Router.swapExactTokensForETH(
                roundTokens,
                0,
                sellPath,
                address(this),
                block.timestamp
            );     
            uint256 afterEth = address(this).balance.sub(beforeEth);

            rounds[activeRound].totalAmt = rounds[activeRound].totalAmt - roundTokens;
            rounds[activeRound].eth = rounds[activeRound].eth + afterEth;
        }
    }

    function setTaxRate(uint256 _val) external onlyOwner {
        require(tax <= 10 && tax > 0, "Tax must be between 1 and 10");
        tax = _val;
    }

    function getTaxRate() public view returns (uint256) {
        return tax;
    }

    function setDuration(uint256 val) external onlyOwner {
        roundDuration = val;
    }

    function toggleTaxOn() external onlyOwner {
        taxOn = !taxOn;
    }

    function getTaxOn() public view returns (bool) {
        return taxOn;
    }

    function togglePot() external onlyOwner {
        growPot = !growPot;
    }

    function getPot() public view returns (bool) {
        return growPot;
    }

    function setExcluded(address _val, bool exclude) external onlyOwner {
        excluded[_val] = exclude;
    }

    receive() external payable {}

    function rescueEth() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueTokens(address _stuckToken, uint256 _amount) external onlyOwner {
        IERC20(_stuckToken).transfer(msg.sender, _amount);
    }

    function toHex(bytes32 data) public pure returns (string memory) {
		return string(abi.encodePacked("0x", toHex16(bytes16(data)), toHex16(bytes16(data << 128))));
	}

	function toHex16(bytes16 data) internal pure returns (bytes32 result) {
		result =
			(bytes32(data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
			((bytes32(data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64);
		result =
			(result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
			((result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32);
		result =
			(result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
			((result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16);
		result =
			(result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
			((result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8);
		result =
			((result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4) |
			((result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8);
		result = bytes32(
			0x3030303030303030303030303030303030303030303030303030303030303030 +
				uint256(result) +
				(((uint256(result) + 0x0606060606060606060606060606060606060606060606060606060606060606) >> 4) &
					0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
				7
		);
	}

    function requestRandomWords() private {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;

        uint256 winnerIndex1 = randomWords[0] % lottoTickets.length;
        uint256 winnerIndex2 = randomWords[1] % (lottoTickets.length - 1);
        uint256 winnerIndex3 = randomWords[2] % (lottoTickets.length - 2);

        lottoTicket memory winnerTicket1 = lottoTickets[winnerIndex1];
        lottoTicket memory winnerTicket2 = lottoTickets[winnerIndex2];
        lottoTicket memory winnerTicket3 = lottoTickets[winnerIndex3];

        winningLottoTicket1 = winnerTicket1.lottoTicket;
        winningLottoTicket2 = winnerTicket2.lottoTicket;
        winningLottoTicket3 = winnerTicket3.lottoTicket;

        uint256 totalWinnerTokens = winnerTicket1.tokens + winnerTicket2.tokens + winnerTicket3.tokens;

        uint256 winner1ETH = rounds[activeRound].eth.mul(winnerTicket1.tokens.div(totalWinnerTokens)).div(totalWinnerTokens);
        winnerTicket1.ethWon = winner1ETH;
        lottoTicketWinners.push(winnerTicket1);

        uint256 winner2ETH = rounds[activeRound].eth.mul(winnerTicket2.tokens.div(totalWinnerTokens)).div(totalWinnerTokens);
        winnerTicket2.ethWon = winner2ETH;
        lottoTicketWinners.push(winnerTicket2);

        uint256 winner3ETH = rounds[activeRound].eth.mul(winnerTicket3.tokens.div(totalWinnerTokens)).div(totalWinnerTokens);
        winnerTicket3.ethWon = winner3ETH;
        lottoTicketWinners.push(winnerTicket3);

        payable(winnerTicket1.user).transfer(winner1ETH);
        payable(winnerTicket2.user).transfer(winner2ETH);
        payable(winnerTicket3.user).transfer(winner3ETH);

        //Start Next Round
        uint256 newRound = activeRound + 1;
        rounds[newRound].launched = true;
        rounds[newRound].expire = block.timestamp + roundDuration;
        launchTime = block.timestamp;
        activeRound = activeRound + 1;                
    }
}