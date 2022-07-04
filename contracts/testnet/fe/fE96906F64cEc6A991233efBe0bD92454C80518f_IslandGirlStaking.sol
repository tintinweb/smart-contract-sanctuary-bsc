// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
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

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract IslandGirlStaking is Ownable, KeeperCompatibleInterface {

    IBEP20 public  acceptedToken;

    uint8 private _decimals = 9;

    uint256 public flexibleBasisPoints;
    uint256 public oneMonthBasisPoints;
    uint256 public threeMonthsBasisPoints;
    uint256 public sixMonthsBasisPoints;
    uint256 public twelveMonthsBasisPoints;
    uint256 public interval;

    mapping(address => uint256) public depositStart;
    mapping(address => uint256) public IslandGirlBalanceOf;
    mapping(address => bool) public isDeposited;
    mapping(address => uint256) public depositOption;
    mapping(uint256 => uint256) public stakingPeriod;
    event DepositEvent(
        address indexed user,
        uint256 IGIRLAmount,
        uint256 timeStart
    );
    event WithdrawEvent(
        address indexed user,
        uint256 IGIRLAmount,
        uint256 interest
    );

    constructor(
        address _acceptedToken,
        uint256 _flexible,
        uint256 _30bps,
        uint256 _90bps,
        uint256 _180bps,
        uint256 _360bps
    ) {
        acceptedToken = IBEP20(_acceptedToken);
        flexibleBasisPoints = _flexible;
        oneMonthBasisPoints = _30bps;
        threeMonthsBasisPoints = _90bps;
        sixMonthsBasisPoints = _180bps;
        twelveMonthsBasisPoints = _360bps;
        interval = 1000*3600*24;
        stakingPeriod[0]=0;
        stakingPeriod[1]=30;
        stakingPeriod[2]=90;
        stakingPeriod[3]=180;
        stakingPeriod[4]=360;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - depositStart[msg.sender]) > interval*stakingPeriod[depositOption[msg.sender]];
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - depositStart[msg.sender]) > interval*stakingPeriod[depositOption[msg.sender]] && depositOption[msg.sender] != 0 && isDeposited[msg.sender]) {
            withdraw();
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }
    function deposit(uint256 _amount, uint256 _option) external {
        require(_amount >= 0, "Error, deposit must be >= 0");
        require(isDeposited[msg.sender]==false, "Error, you have already deposited");

        IslandGirlBalanceOf[msg.sender] += _amount;
        depositStart[msg.sender] = block.timestamp;
        isDeposited[msg.sender] = true; 
        depositOption[msg.sender] = _option;

        acceptedToken.transferFrom(msg.sender, address(this), _amount);
        emit DepositEvent(msg.sender, IslandGirlBalanceOf[msg.sender], depositStart[msg.sender]);
    }

    function testtransfer(address to, uint256 amount) external {
        acceptedToken.transferFrom(msg.sender, to, amount);
    } 
    function withdraw() public {
        require(isDeposited[msg.sender] == true, "Error, no previous deposit");

        uint256 interest = calculateInterests(msg.sender);
        uint256 userBalance = IslandGirlBalanceOf[msg.sender];

        //reset depositer data
        IslandGirlBalanceOf[msg.sender] = 0;
        isDeposited[msg.sender] = false;
        //send funds to user
        // _mint(msg.sender, interest);
        acceptedToken.transfer(msg.sender, interest);
        acceptedToken.transfer(msg.sender, userBalance);

        emit WithdrawEvent(msg.sender, userBalance, interest);
    }

    function withdrawInterests() public {
        require(isDeposited[msg.sender] == true, "Error, no previous deposit");

        uint256 interest = calculateInterests(msg.sender);

        // reset depositStart

        depositStart[msg.sender] = block.timestamp;
        acceptedToken.transfer(msg.sender, interest);
        //_mint(msg.sender, interest);
    }

    // calculates the interest for each second on timestamp

    function calculateInterests(address _user)
        public
        view
        returns (uint256 insterest)
    {
        // get balance and deposit time
        uint256 userBalance = IslandGirlBalanceOf[_user];
        uint256 depositTime = block.timestamp - depositStart[msg.sender];
        uint256 option = depositOption[msg.sender];

        // calculate the insterest per year

        uint256 basisPoints = getBasisPoints(option);
        uint256 interestPerMili = (userBalance * basisPoints) /
            (100 * 30 * 24 * 3600 * 1000);

        // get the interest on depositTime

        uint256 interests = interestPerMili * (depositTime);

        return interests;
    }

    function getBasisPoints(uint256 _option)
        public
        view
        returns (uint256 basisPoints)
    {
        if (_option == 0) {
            return flexibleBasisPoints;
        } else if (_option == 1) {
            return threeMonthsBasisPoints;
        } else if (_option == 2) {
            return sixMonthsBasisPoints;
        } else if (_option == 3) {
            return twelveMonthsBasisPoints;
        } else if (_option == 4) {
            return twelveMonthsBasisPoints;
        }
    }

    function getStakingInfo(address user) public view returns (uint256 startTime, uint256 balance, uint256 option ) {
        return (depositStart[user], IslandGirlBalanceOf[user], depositOption[user]) ;
    }
}