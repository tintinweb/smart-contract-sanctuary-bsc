// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Strings.sol";
import "./ERC1155.sol";
import "./IERC20.sol";
import "./IBENC.sol";

contract BENC is ERC1155, IERC20, IBENC {
    uint256 public tokenID_1;
    uint256 public tokenID_2;
    string _name;
    string public _uri_header;
    uint256 _totalSupply;
    string _symbol;
    uint256 public mintCounter = 0;
    address private _owner;
     uint256 public numberOfMinters =0;
    mapping(address => uint256) _balances;
    uint256 public maxSupply = 10000;
    uint256 public price = 0.00001 ether;
    uint256 public maxWallet = 3;
    uint256 public saleExpiredDate = block.timestamp+ 360 days;
    address deployer;
    mapping (address=>bool) Dispatcher;

    modifier onlyDispatchers(address dispatcher){
        require(Dispatcher[dispatcher],"You are not a dispatcher");
        _;
    }
      
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
     mapping(uint256=>NFTCollection) public physicalNFT;
       mapping(uint256=>NFTCollection) public ownerNFT;
     mapping(address=> uint256[]) public tracker;
    mapping(address=>bool) included;
       address[] public minters;
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

    constructor(string memory uriheader,string memory name_,string memory symbol_,uint256 _tokenId_1,uint256 _tokenId_2)
        ERC1155(string(abi.encodePacked(uriheader, "{id}", ".json")))
    {
        tokenID_1 = _tokenId_1;
        tokenID_2 = _tokenId_2;
        _symbol = symbol_;
        _name = name_;
        address msgSender = _msgSender();
        deployer =  msgSender;
        _owner =  deployer;

        emit OwnershipTransferred(address(0), msgSender);
        setURIheader(uriheader);
        saleExpiredDate = block.timestamp+ 360 days;
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
     * Ether and Wei. This is the value {BENC} uses, unless this function is
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
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
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
    
   

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the mintCounter `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        setApprovalForAll(spender, true);
        return true;
    }



    function setMaxWallet(uint256 max) public onlyOwner {
        maxWallet = max;
    }

    function setMaxMintable(uint256 max) public onlyOwner {
        maxSupply = max;
    }

    function setPrice(uint256 _price_0_01_unit) public onlyOwner {
        price = _price_0_01_unit * 0.01 ether;
    }

    function setEventDate(uint256 timestamp) public onlyOwner{
        saleExpiredDate = timestamp;
    }
  
      function mintNFT(uint256 amount,string memory phonenumber,string memory email) public payable {
      require(canMint,"Minting Expired");
      
        uint256 userValue = balanceOf(_msgSender());
        uint256 total = price * amount;

        uint256 maximumAfterMint = mintCounter + amount;
        require(maximumAfterMint < maxSupply, "BNUG: Maximum Exceeded");
        require(userValue < maxWallet, "Maximum Wallet NFT Exceeded");
        require(msg.value >= total, "Insufficient Amount");

        _mint(msg.sender, tokenID_1, amount,"");
        _mint(msg.sender, tokenID_2, amount,"");      
        _mintERC20(msg.sender, amount);
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
     
       if(!included[_msgSender()]){       
        minters.push(_msgSender());      
        included[_msgSender()] = true;
       numberOfMinters++;

       }
    }

    function getTracker(address owner_) public  view returns(uint256[] memory) {
            return  tracker[owner_];
    }

    function getonwerNFT(uint256 tracknumber) public view returns(NFTCollection memory){
            return ownerNFT[tracknumber];
    }

    function getMinters() public view returns(address[] memory){
        return minters;
    }

     function transfer(address to, uint256 amount_)
        public
        virtual
        override
        returns (bool)
    {

        
        address owner_ = _msgSender();
        transferNFT(owner_, to, amount_," ", " ");

    
      
        return true;
    }
   
function transferNFT(address from, address to , uint256 amount, string memory phonenumber,string memory email)
 public {   
  
    uint256 sellerBalance = balanceOf(from);       
   
    require(amount<=sellerBalance,"Amount want to transfer is greater than sellerBalance");

      OwnerProperty memory currentOwner =  OwnerProperty({owner:to,phoneNumber:phonenumber,emailAddress:email}); 
         amount = 1;
        for(uint256 y = 0; y<tracker[from].length;y++){
            uint256 trackN = tracker[from][y];

            if(!ownerNFT[trackN].collected){
             ownerNFT[trackN].previousOwner = ownerNFT[trackN].owner;       
              ownerNFT[trackN].owner=currentOwner;  //changeOwnership      
             tracker[to].push(trackN);  // create new tracker
             tracker[from].pop();   // delete the seller tracker
                amount +=1;
                
            }
        }

       // amount = amt;
       
  /*       for(uint256 x = amount;x>0;x--){     
         //get trackNumber  
         uint256 l = temptrackN.length-1;
         uint256 trackNumber = temptrackN[l];
         ownerNFT[trackNumber].previousOwner = ownerNFT[trackNumber].owner;       
         ownerNFT[trackNumber].owner=currentOwner;  //changeOwnership      
         tracker[to].push(trackNumber);  // create new tracker
         tracker[from].pop();   // delete the seller tracker
    }
*/
       _transfer(from, to, amount);
        safeTransferFrom(from, to, tokenID_1, amount, "0x0");
        safeTransferFrom(from, to, tokenID_2, amount, "0x0");

       
}
   
   
    function openMinting(bool enable) public onlyOwner{
        canMint =enable;

    }

    function editProfile(string memory phonenumber, string memory email) public  {
        uint256 balance = balanceOf(_msgSender());
        require(balance>0,"You are not the owner of this NFT");
        uint256[] memory tkr = tracker[_msgSender()];
        OwnerProperty memory onwerProperty = OwnerProperty({phoneNumber:phonenumber, emailAddress:email,owner:_msgSender()});
      
        for (uint256 x= 0; x<tkr.length;x++){
            uint256 tracknumber = tkr[x];
            ownerNFT[tracknumber].owner = onwerProperty;
        }
    }



    function addDispatcher (address dispatcher, bool value) public onlyOwner{
            Dispatcher[dispatcher] = value;
    }

    function markAsCollected(uint256 tracknumber ) public onlyDispatchers(_msgSender()) {

        require(!ownerNFT[tracknumber].collected,"This NFT is already Collected");     
        ownerNFT[tracknumber].collected = true;
        physicalNFT[tracknumber] = ownerNFT[tracknumber];
    
    }

    function reverseCollected(uint256 tracknumber ) public onlyOwner {

        require(!ownerNFT[tracknumber].collected,"This NFT is already Collected");     
        ownerNFT[tracknumber].collected = false;
        physicalNFT[tracknumber] = ownerNFT[tracknumber];
    
    
    }

    function viewCollector(uint256 tracknumber) public view returns(NFTCollection memory) {
            require(physicalNFT[tracknumber].collected,"This NFT is already Collected");   
            return physicalNFT[tracknumber];
    }
    
    function transferBNB() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(_msgSender()).transfer(amountBNB);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BENC}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the mintCounter `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
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

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "BENC: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BENC: transfer from the zero address");
        require(to != address(0), "BENC: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BENC: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mintERC20(address account, uint256 amount) internal virtual {
        require(account != address(0), "BENC: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burnERC20(address account, uint256 amount) internal virtual {
        require(account != address(0), "BENC: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BENC: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BENC: approve from the zero address");
        require(spender != address(0), "BENC: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "BENC: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
}