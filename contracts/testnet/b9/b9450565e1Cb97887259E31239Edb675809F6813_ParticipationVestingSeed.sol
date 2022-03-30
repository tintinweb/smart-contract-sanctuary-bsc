/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity ^0.8.0;
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// ParticipationVesting smart contract
contract ParticipationVestingSeed  {


    uint public totalTokensToDistribute;
    uint public totalTokensWithdrawn;
    uint public initialRelease;


    struct Participation {
        uint256 initialPortion;
        uint256 vestedAmount;
        uint256 amountPerPortion;
        bool initialPortionWithdrawn;
        bool [] isVestedPortionWithdrawn;
    }

    IERC20 public token;

    address public adminWallet=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public signer;
    mapping(address => Participation) public addressToParticipation;
    mapping(address => bool) public hasParticipated;
     mapping(address =>bool) public iswhitelistedAddress;

    uint public initialPortionUnlockingTime;
    uint public numberOfPortions;
    uint [] distributionDates;

    modifier onlyAdmin {
        require(msg.sender == adminWallet, "OnlyAdmin: Restricted access.");
        _;
    }
    modifier iswhitelisted(address _addr){
        require(iswhitelistedAddress[_addr],"Not a Whitelisted Project");
        _;
    }

    /// Load initial distribution dates
    constructor (
        uint _totalLinearUnits,
        uint timeBetweenUnits,
        uint linearStartDate,
        uint _startDate,
        address _token, 
        uint initialPercentage
    )
    {
        // Store number of portions
        numberOfPortions = _totalLinearUnits;
        // Time when initial portion is unlocked
        initialPortionUnlockingTime = _startDate;



        // Set distribution dates
        for(uint i = 0 ; i < _totalLinearUnits; i++) {
            distributionDates.push(linearStartDate + i*timeBetweenUnits);
        }
        // Set the token address
        token = IERC20(_token);
        // Set Initial Release percentage
        initialRelease= initialPercentage;
        signer = msg.sender;
    }

    // Function to register multiple participants at a time
    function registerParticipants(
        address [] memory participants,
        uint256 [] memory participationAmounts
    )
    external
    iswhitelisted(msg.sender)
    {
        for(uint i = 0; i < participants.length; i++) {
            registerParticipant(participants[i], participationAmounts[i]);
        }
    }

     
    

    /// Register participant
    function registerParticipant(
        address participant,
        uint participationAmount
    )
    internal
    {
        require((totalTokensToDistribute -(totalTokensWithdrawn) + (participationAmount)) <= token.balanceOf(address(this)),
            "Safeguarding existing token buyers. Not enough tokens."
        );

        totalTokensToDistribute = totalTokensToDistribute + (participationAmount);

        require(!hasParticipated[participant], "User already registered as participant.");

        uint initialPortionAmount = (participationAmount) *(initialRelease) /(100);
        // Vested 90%
        uint vestedAmount = participationAmount - (initialPortionAmount);

        // Compute amount per portion
        uint portionAmount = vestedAmount / (numberOfPortions);
        bool[] memory isPortionWithdrawn = new bool[](numberOfPortions);

        // Create new participation object
        Participation memory p = Participation({
            initialPortion: initialPortionAmount,
            vestedAmount: vestedAmount,
            amountPerPortion: portionAmount,
            initialPortionWithdrawn: false,
            isVestedPortionWithdrawn: isPortionWithdrawn
        });

        // Map user and his participation
        addressToParticipation[participant] = p;
        // Mark that user have participated
        hasParticipated[participant] = true;
    }


    // User will always withdraw everything available
    function withdraw()
    external
    {
        address user = msg.sender;
        require(hasParticipated[user] == true, "Withdraw: User is not a participant.");

        Participation storage p = addressToParticipation[user];

        uint256 totalToWithdraw = 0;

        // Initial portion can be withdrawn
        if(!p.initialPortionWithdrawn && block.timestamp >= initialPortionUnlockingTime) {
            totalToWithdraw = totalToWithdraw + (p.initialPortion);
            // Mark initial portion as withdrawn
            p.initialPortionWithdrawn = true;
        }


        // For loop instead of while
        for(uint i = 0 ; i < numberOfPortions ; i++) {
            if(isPortionUnlocked(i) == true && i < distributionDates.length) {
                if(!p.isVestedPortionWithdrawn[i]) {
                    // Add this portion to withdraw amount
                    totalToWithdraw = totalToWithdraw + (p.amountPerPortion);

                    // Mark portion as withdrawn
                    p.isVestedPortionWithdrawn[i] = true;
                }
            }
        }

        // Account total tokens withdrawn.
        totalTokensWithdrawn = totalTokensWithdrawn +(totalToWithdraw);
        // Transfer all tokens to user
        token.transfer(user, totalToWithdraw);
    }



    function isPortionUnlocked(uint portionId)
    public
    view
    returns (bool)
    {
        return block.timestamp >= distributionDates[portionId];
    }


    function getParticipation(address account)
    external
    view
    returns (uint256, uint256, uint256, bool, bool [] memory)
    {
        Participation memory p = addressToParticipation[account];
        bool [] memory isVestedPortionWithdrawn = new bool [](numberOfPortions);

        for(uint i=0; i < numberOfPortions; i++) {
            isVestedPortionWithdrawn[i] = p.isVestedPortionWithdrawn[i];
        }

        return (
            p.initialPortion,
            p.vestedAmount,
            p.amountPerPortion,
            p.initialPortionWithdrawn,
            isVestedPortionWithdrawn
        );
    }

    // Get all distribution dates
    function getDistributionDates()
    external
    view
    returns (uint256 [] memory)
    {
        return distributionDates;
    }
        // Whitelist Project Owners
    function AddProjectOnwer(address _addr) external onlyAdmin{
        iswhitelistedAddress[_addr]=true;
    }
     function depositToken(uint amount) public  {
        token.transferFrom(msg.sender, address(this), amount);
    }

}

contract factory is Ownable {
    //  IERC20 public token; 
     mapping(address => bool ) public iswhitelistedAddress;

    ParticipationVestingSeed[] public vestedContract;
    modifier iswhitlisted(address _addr){
        require(iswhitelistedAddress[_addr],"Not a Whitelisted Owner");
        _;
    }
    function create_project (

        uint _totalLinearUnits,//total vesting units
        uint timeBetweenUnits,
        uint linearStartDate,//linear startdat
        uint _startDate, // startdate
        address _token ,
        uint initialPercentage) external iswhitlisted(msg.sender) {

    ParticipationVestingSeed projects = new ParticipationVestingSeed(_totalLinearUnits,
                                                                      timeBetweenUnits,
                                                                      linearStartDate,
                                                                      _startDate,
                                                                      _token,
                                                                      initialPercentage
                                                                       );
            
        vestedContract.push(projects);
    }
    function getProjectCount() public view  returns(uint count){
      return  vestedContract.length;
    }
    function lastIndex() public view returns(uint count){
        return vestedContract.length-1;
    }
    function WhitelistOwners(address _addr) external onlyOwner{
        iswhitelistedAddress[_addr]=true;
    }
    function removeOnwers(address _addr) external onlyOwner{
        require(iswhitelistedAddress[_addr],"Project Owner Not Found");
        iswhitelistedAddress[_addr] = false;
    }
 
}