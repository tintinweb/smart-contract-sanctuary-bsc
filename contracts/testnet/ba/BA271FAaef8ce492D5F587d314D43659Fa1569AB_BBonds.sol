// SPDX-License-Identifier: MIT
pragma solidity <=0.8.13;

import "./ERC721.sol";
import "./Counters.sol";
import "./IERC20.sol";

contract BBonds is ERC721 {

    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _tokenIds;
    mapping (uint256 => uint256[6]) private bondDetails;
    uint public PRICE = 110000; //0.0011 BTC
    uint256 public MAX_Supply = 10000;
    uint256 private WhiteBallMaxNum = 52;
    uint256 private RedBallMaxNum = 10;
    address private tokenContract;

    event buyBond(address indexed to, uint256 indexed tokenId, uint256[6] bondNumber);

    // Represents the status of the purchaseStatus
    enum Status {
        NotStarted,     // The purchaseStatus has not started yet 
        Open,           // The lotpurchaseStatustery is open for bond purchases 
        Closed,         // The lopurchaseStatusttery is no longer open for bond purchases
        Completed       // The purchaseStatus has been closed and the numbers drawn
    }

    Status purchaseStatus;    

    constructor(string memory _name, string memory _symbol, address _tokenContract) ERC721(_name,_symbol) {
        purchaseStatus = Status.NotStarted;
        tokenContract = _tokenContract;
    }

    /**
     * @dev See {BBonds-buyBBond}.
     * Its payable method, payment amount is PRICE of token which defined.
     * output : mint NFT to msg.sender
     */
    function buyBBond(address mintAddress) public payable whenNotPaused onlyOwner() returns (uint256)
    {
        require(purchaseStatus == Status.Open, "Purchase still not started.");
        //require(msg.value >= PRICE, "Not enough ether to purchase bond.");
        require(totalSupply() < MAX_Supply, "Max supply exceed,No more NFT can mint");
        
        uint256[6] memory _bondNumbers = generateBondNumber();

        //require(duplicateBond(_bondNumbers) == true, "Duplicate bondId"); 
        if(PRICE > 0)
        {
            IERC20 token = IERC20(address(tokenContract));
            uint allowance = token.allowance(msg.sender,address(this));
            require(allowance >= PRICE, "Not enough balance to purchase bond.");
            require(token.transferFrom(msg.sender, address(this), PRICE), "Fail to deduct bond fees");
        }        
        
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(mintAddress, newItemId);
        bondDetails[newItemId] = _bondNumbers;
        emit buyBond(mintAddress, newItemId,_bondNumbers);
        return newItemId;
    }

    /**
     * @dev See {BBonds-getBondNumbers}.
     * 
     * output : get bond number by tokenId
     */
    function getBondNumbers(uint256 tokenId) external view returns (uint256[6] memory) {
        return bondDetails[tokenId];
    }

    /**
     * @dev See {BBonds-getCurrentTokenContract}.
     * 
     * output : get current token contract
     */
    function getCurrentTokenContract() external onlyOwner() view returns (address) {
        return tokenContract;
    }

    /**
     * @dev See {BBonds-getNumberRange}.
     * 
     * output : get number range
     */
    function getNumberRange() external onlyOwner() view returns (uint256[2] memory) {        
        uint256[2] memory range;
        range[0]=WhiteBallMaxNum;
        range[1]=RedBallMaxNum;
        return range;
    }

    /**
     * @dev See {BBonds-startPurchase}.
     */
    function startPurchase() public onlyOwner() {
        require((purchaseStatus == Status.NotStarted || purchaseStatus == Status.Completed), "Purchase still not completed.");
        purchaseStatus = Status.Open;
    }

    /**
     * @dev See {BBonds-endPurchase}.
     */
    function endPurchase() public onlyOwner() {
        require(purchaseStatus == Status.Open, "Purchase still not open.");        
        purchaseStatus = Status.Closed;
    }

    /**
     * @dev See {BBonds-completePurchase}.
     */
    function completePurchase() public onlyOwner() {
        require(purchaseStatus == Status.Closed, "Purchase still not closed.");
        purchaseStatus = Status.Completed;
    }

    /**
     * @dev See {BBonds-updateBondPrice}.
     */
    function updateBondPrice(uint price) public onlyOwner() {
        PRICE = price;
    }

    /**
     * @dev See {BBonds-updateMaxSupply}.
     */
    function updateMaxSupply(uint amount) public onlyOwner() {        
        MAX_Supply = MAX_Supply.add(amount);
    }

    /**
     * @dev See {BBonds-updateBondNumberRange}.
     *  changeRandom number generation sequnce range
     */
    function updateBondNumberRange(uint whiteBallNum, uint redBallNum) public onlyOwner() {        
        WhiteBallMaxNum = whiteBallNum;
        RedBallMaxNum = redBallNum;
    }

    /**
     * @dev See {BBonds-updateTokenContract}.
     */
    function updateTokenContract(address contractAddress) public onlyOwner() {        
        require(contractAddress != address(0), "Invalid address");
        tokenContract = contractAddress;
    }    

    /**
     * @dev See {BBonds-duplicateBond}.
     * Find duplicate bond numbers
     */
    function duplicateBond(uint256[6] memory _bondNumbers) internal view returns (bool) {

        uint256 value = 0;
        for (uint i=1; i <= _tokenIds.current(); i++) {
            bytes32 oldString = keccak256(abi.encodePacked(bondDetails[i]));
            bytes32 newString = keccak256(abi.encodePacked(_bondNumbers));
            if(oldString == newString)
            {
                value = 1;
            }            
        }
        if(value == 1)
        {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @dev See {BBonds-generateBondNumber}.
     */
    function generateBondNumber() internal view returns(uint256[6] memory) {
        uint256[6] memory Bond;
        
        Bond[0] = random(WhiteBallMaxNum,1);
        Bond[1] = random(WhiteBallMaxNum,2);
        Bond[2] = random(WhiteBallMaxNum,3);
        Bond[3] = random(WhiteBallMaxNum,4);
        Bond[4] = random(WhiteBallMaxNum,5);
        Bond[5] = random(RedBallMaxNum,6);
             
        return Bond;        
    }

    function random(uint number,uint i) internal view returns(uint) {    
        uint randNum = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender,i))) % number;
        if(randNum == 0)
        {
            randNum += 1;
        }
        return randNum;         
    }

    /**
     * @dev Burns `tokenId`. See {BBonds-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public whenNotPaused virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        delete bondDetails[tokenId];
        _burn(tokenId);
    }

    /**
     * @dev See {BBonds-withdraw}.
     * Owner will withdraw Bond fee
     */
    function withdraw() public onlyOwner() {
        IERC20 token = IERC20(address(tokenContract));
        uint balance = token.balanceOf(address(this));
        require(balance > 0, "No any fund to withdraw");
        require(token.transfer(msg.sender, balance), "Fail to withdraw process");        
    }    

    /**
     * @dev See {BBonds-withdraw}.
     * Owner define tokenId holder to winner
     */
    function winnerIs(uint256 tokenId) public onlyOwner() {
        setTokenAsWinner(tokenId);
    }
}