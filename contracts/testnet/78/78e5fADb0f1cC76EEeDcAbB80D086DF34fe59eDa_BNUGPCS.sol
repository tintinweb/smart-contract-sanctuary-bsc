// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Strings.sol";
import "./ERC1155.sol";

contract BNUGPCS is ERC1155{
    uint256 public tokenID_1;
    string _name;
    string  _uri_header;
    uint256 _totalSupply;
    string _symbol;
    uint256 public mintCounter = 0;
    address private _owner;
    uint256 public numberOfDonors =0;
    mapping(address => uint256) _balances;
    uint256 public minDonationAmount = 0.00001 ether;
    uint256 public saleExpiredDate = block.timestamp+ 360 days;
    address private deployer;
         
       struct  OwnerProperty {
        string phoneNumber;
        string emailAddress;
        address owner;
    }
        struct NFTCollection{
        OwnerProperty owner;
        OwnerProperty previousOwner;
        bool collected;
    }

     mapping(uint256=>NFTCollection) public ownerNFT;
     mapping(address=> uint256[]) public tracker;
    mapping(uint256=>mapping(address=>bool)) included;
        uint256 public weekz =0;
        uint256 public startDate = block.timestamp;
        uint256 public endDate = block.timestamp;
         uint256 public nextTime = 0;
        address public marketingWallet = 0x491b8Dea8Fd6Aa68a9EBa6a97376f910a415364A;
    
     mapping(uint256 =>address[] ) public donors;
        
    bool public canMint =true;
    mapping(address => mapping(address => uint256)) _allowances;
  
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

     mapping(address=>bool) entrance;
    modifier blockRentrancy(address from){    
    require(entrance[from],"Rentrancy Blocked");
    entrance[from] = false;
    _;
    entrance[from] = true;
}

    constructor(string memory uriheader,string memory name_,string memory symbol_,uint256 _tokenId_1)
        ERC1155(string(abi.encodePacked(uriheader, "{id}", ".json")))
    {
        tokenID_1 = _tokenId_1;       
        _symbol = symbol_;
        _name = name_;
        address msgSender = _msgSender();
        deployer =  msgSender;
        _owner =  deployer;

        emit OwnershipTransferred(address(0), msgSender);
        setURIheader(uriheader);
        saleExpiredDate = block.timestamp+ 90 days;
    }

     function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        id = tokenID_1;
       
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function uri(uint256 _tokenid)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    _uri_header,
                    Strings.toString(_tokenid),
                    ".json"
                )
            );
    }

 
    function setURIheader(string memory uri_head) public onlyOwner{
        _uri_header = uri_head;
    }

      function getURIheader() public view  returns(string memory){
        return _uri_header;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BNUGPCS} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 0;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }

     /*function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }*/

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */

  

    function setPrice(uint256 _price_0_01_unit) public onlyOwner {
        minDonationAmount = _price_0_01_unit * 0.01 ether;
    }

    function setExpiredDate(uint256 timestamp) public onlyOwner{
        saleExpiredDate = timestamp;
    }
  
      function supportCandidate(uint256 amount,string memory phonenumber,string memory email) public payable {
       require(canMint,"Minting Expired");      
        uint256 total = minDonationAmount * amount;
        require(msg.value >= total, "Insufficient Amount");
         _supportCandidate(amount,phonenumber,email);
          transferForMarketing(msg.value);
    }
    function _supportCandidate(uint256 amount,string memory phonenumber,string memory email) public  {
        _mint(msg.sender, tokenID_1, amount,"");    
        mintCounter += amount; 
       createNFTcode(amount,phonenumber,email);  
      
         
    }

   
    function createNFTcode(uint256 amount,string memory phonenumber,string memory email) internal {      
        OwnerProperty memory currentOwner =  OwnerProperty({owner:_msgSender(),phoneNumber: phonenumber,emailAddress:email}) ;
         OwnerProperty memory previousOwner =  OwnerProperty({owner:address(0),phoneNumber: " ",emailAddress:" "}) ;
      
       for(uint256 x = 0; x<amount;++x){
        uint256 trackNumber = block.timestamp+x;
        
        ownerNFT[trackNumber]=NFTCollection({owner:currentOwner, previousOwner:previousOwner,collected:false}); 
        tracker[_msgSender()].push(trackNumber);
     
       }


        uint256 dateDiff = endDate-startDate;
        weekz = dateDiff/(1 weeks);   
        endDate = block.timestamp;          
     
       if(!included[weekz][_msgSender()]){
        donors[weekz].push(_msgSender());      
        included[weekz][_msgSender()] = true;
        numberOfDonors++;
       
       }

    }
    
    function startLottery() public onlyOwner{
        
        startDate = block.timestamp;
        endDate = block.timestamp;
        
    }

    function getTracker(address owner_) public  view returns(uint256[] memory) {
            return  tracker[owner_];
    }

    function getonwerNFT(uint256 tracknumber) public view returns(NFTCollection memory){
            return ownerNFT[tracknumber];
    }

    function getDonors(uint256 _week) public view returns(address[] memory){
        return donors[_week];
    }

 // transferNFT(owner_, to, amount_," ", " ");
     //   transferForMarketing();
   
function transferNFT(address from, address to , uint256 amount, string memory phonenumber,string memory email)
 public {   
  
    uint256 sellerBalance = balanceOf(from,tokenID_1);       
   
    require(amount<=sellerBalance,"Amount want to transfer is greater than sellerBalance");

      OwnerProperty memory currentOwner =  OwnerProperty({owner:to,phoneNumber:phonenumber,emailAddress:email}); 
       uint256  amt = 0;
              
        for(uint256 y = 0; y<tracker[from].length && amt<amount ; ){
            uint256 trackN = tracker[from][y];
           
            if(!ownerNFT[trackN].collected){
             ownerNFT[trackN].previousOwner = ownerNFT[trackN].owner;       
              ownerNFT[trackN].owner=currentOwner;  //changeOwnership      
             tracker[to].push(trackN);  // create new tracker              
            
            tracker[from][y] = tracker[from][tracker[from].length-1];            
             tracker[from].pop();   // delete the seller tracker 3    
                amt +=1;
                y=0;            
             
            }
            else{y++; }
            
        }


        string memory message = string(abi.encodePacked("You cannot transfer NFT you collected, Max: Transfer = ",
        Strings.toString(amt)," or less"));
       require(amount<=amt,message);
       
            
}
   
   
    function openMinting(bool enable) public onlyOwner{
        canMint =enable;

    }

    function editProfile(string memory phonenumber, string memory email) public  {
        uint256 balance = balanceOf(_msgSender(),tokenID_1);
        require(balance>0,"You are not the owner of this NFT");
        uint256[] memory tkr = tracker[_msgSender()];
        OwnerProperty memory onwerProperty = OwnerProperty({phoneNumber:phonenumber, emailAddress:email,owner:_msgSender()});
      
        for (uint256 x= 0; x<tkr.length;x++){
            uint256 tracknumber = tkr[x];
            ownerNFT[tracknumber].owner = onwerProperty;
        }
    }


    
    function transferAllBNB() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(_msgSender()).transfer(amountBNB);
    }
       
       
        function setMarketingWallet(address wallet) public onlyOwner{
            marketingWallet = wallet;
        }
     
      function transferForMarketing(uint256 value) internal {    
        uint256 amountBNB = (value *10)/100;
        payable(marketingWallet).transfer(amountBNB);   
         nextTime = block.timestamp + 7 days;        
        

        
    }

       /**
     * @dev Returns the address of the current owner.
     */
    function getOwner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender() || deployer == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    receive() external payable{
             
        uint256 amount = msg.value/minDonationAmount;
        uint total = amount*minDonationAmount;
        require(total>0,"Value is Zero");
       require(canMint,"Minting Expired");      
       require(msg.value >= total, "Insufficient Amount");
       _mint(msg.sender, tokenID_1, amount,"");
        mintCounter += amount; 
       // createNFTcode(amount,"","");
        transferForMarketing(msg.value); 
    }

}