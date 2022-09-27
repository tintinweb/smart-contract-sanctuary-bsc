/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: TopacioSubscription.sol


pragma solidity >=0.8.7;
/*
 * @title TopacioSubscription
 * @dev Subscriptions Topacio - Julio Vinachi
 * @url https://github.com/topaciotrade/smart-contracts-subscription/blob/main/TopacioSubscription.sol
 * ver 1.0.17
 */




interface IERC721Collection {
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
        function setMaxWallet(uint256 amountLimit) external;
        function getContract() external view returns(address);
        function safeMint(address to, string memory uri) external;
        function lastToken() external view returns (uint256);
        function safeTransferFrom(address sender, address to, uint256 TokenID) external;
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TopacioSubscription is IERC721Receiver{

    uint lastSubscription;
    uint priceOfSubscription = 100000000000000000;  
    bool newSubscriptionEnable = false;
    bool isActiveCustomToken = false;
    uint maxNewSubscriptors = 50;  
    uint controlTotalSubscriptors = 0;
    uint controlNewSubscriptor = 0;
    uint controlNftStorage = 0;
    uint rateByClaim = 3;
    uint public availableFragments = 100;
    IERC20 public token;
    IERC721Collection public instanceNFTs;

    address payable public stakingInfrastructure = payable(0xc2133D7f29e8E2543ecB5B732b07Fe058C26778E);
    
    struct Subscription {
        uint controldate; // initial start date
        bool active;  // if true, active
        address delegate; // person delegated to
        uint amountSubscription;
        uint nro;
        uint tikets;
        string telegramLink;
        uint endsubscription; // final date subscription
    }

    struct NftsStorage {
        uint256 nftId;
    }

    address[] public addressSubscriptors;
    mapping(address => Subscription) public subscriptions;
    mapping(uint256 => NftsStorage) public nftsStorage;

    address private owner;

    event Received(address, uint);
    event RegisterClaimFragment(address Subscriptior,uint currentDate, uint blockNumber, uint idNFT);
    event NewRegisterSubscriptor(address Subscriptior, uint amount,uint start,uint end);
    event NewSendToStakingInfrastructure(address Subscriptior, uint amount,uint currentDate,uint blockNumber);
    event NewSpendTickets(address Subscriptior, uint amount,uint currentDate, uint blockNumber);
    event NewSpendTicketsByCode(address Subscriptior, uint amount, string code,uint currentDate, uint blockNumber);
    

    string [] fragmentos = [
    'QmXr6yhTEzrpUYyAKN3eekYW6F5L22DNqfKmvuek5cqKkJ',
    'QmRLpXyyNpDaLr6yxGfkknApbsWKKC5XdytJveiKBHK6Jm',
    'Qmbcqjmys9KxyrEecGjrwvKq1Ap3sAyv4FTusqepkmCD4x',
    'QmdrJQhyHeSo7FxSNUBrDL4xvaHXdhdB4v9oNrhHgzz2zY',
    'QmUHbKFUPXDLcuz2A38YshCcbsHn9T6KJAyEewHx4GWkmc',
    'QmUqjCC1NAbMra2MaQoEbeivBiN4aDTtQe4R45MjZ7rJBZ',
    'QmdfkUDHfRCbnkHp4uQZro2tGsEdasooH7v1toqsJriZ55',
    'QmNtmbUcuxkiBpdcUmphxX5y2yox31QcLyvwgDg8TEd6rc',
    'Qme5Kv96pJtkoLQuuYLTgJDNFtZHaSZzEwBezMjvisgXtf',
    'QmSe3xMwdHztvG33pHq2TvtD6Wymm9ssUnfYPZcCbtJZP4',
    'QmVr7YSccU3opKEGT5g7VQ4TZKhhmLQ18yCqcMJMfzTY8Y',
    'QmerTPkkaPJRdNUqWhLoyBkvPM2VdbLJVurm3pqNLA9ciE',
    'QmeNK4HSaH1dtSFJbuQ3JSdhNHthVQczLoiQouXKfmhPbX',
    'QmPRiRxgLTBXbkazBG9PWYr9rjhZRdvHrGWFwn6x8PiVJS',
    'QmVx9M4qnF8t2p8ormP4rTmh6Yjgqw1fXRv7TkvaCSVvfs',
    'QmbHoaam138KXfkNjUUaN5xXp3qAmB8kHKcn5p5pmQLVKU',
    'QmRErUyyFXMzdbP1FuCepuvdEPgcRPcKPSzv3nBPoeQuH9',
    'QmPV5ShEBm9tJ8Ev7Hk6qUuvYchmwwewodaVinrndzxfF1',
    'Qmcf5X1Rcuy7QrTmvtgLCU6CSDjgr1ctAgSbXQ5m83enxj',
    'QmWoc7tPdFGLkKqt3uxdejBoUn9E9JTZVDPUWFqRVN7Dae',
    'QmNj8Zf8g5vHpf8EvtaiTadC9cpJAbxzMqeA5VNLu9ijzN',
    'QmUPjz5TQinyRavbuhTicjXYb21YMw7aTuMwpDkn5xTpzP',
    'QmSurMfysw2vBm6a1GZ2C9yyd3d2NwzBM5EsZ37McCvSNX',
    'QmaqUHzijvd6s5Rby6jjzUQosYPrYG8b5oHEsigZ2Y3qVp'];

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() payable {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"you are not the owner contract");
        _;
    }

    modifier onlySubscriber(){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.delegate == msg.sender,"you are not of this subscriptior");
        _;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
    
    /**
     * Change owner contract
     */
     function changeOwner(address newOwner) onlyOwner public 
    {
        owner = newOwner;
    }

    /**
     * Active Pay Only for token Custom
     */
    function activePayByToken(address _token,uint _initialCost) onlyOwner public 
    {
        isActiveCustomToken = true;
        priceOfSubscription = _initialCost;
        token = IERC20(_token);
    }

    function InactivePayByToken() onlyOwner public returns (bool)
    {
        isActiveCustomToken = false;
        return true;
    }

    function getIsActivePayByToken() external view returns (bool) 
    {
        return isActiveCustomToken;
    }

    function setTelegramLink(address _subscriber, string memory _telegramLink) onlyOwner public 
    {
        Subscription storage consult = subscriptions[_subscriber];
        require(consult.active,"subscriber not exist or is no active");
        consult.telegramLink = _telegramLink;
    }

    function getTelegramLink() onlySubscriber external view returns (string memory) 
    {
        Subscription storage consult = subscriptions[msg.sender];
        return consult.telegramLink;
    }

    function getBalanceInToken() public view returns (uint256)
    {        
        require(isActiveCustomToken == true, "Token is not active");
        return token.balanceOf(address(msg.sender));
    }


    function getDateLastSubscription() external view returns (uint){
        return lastSubscription;
    }

    function comprar() public payable {
        

        require ( maxNewSubscriptors > 0 , "No have quota for new Subscription");  
        require ( newSubscriptionEnable == true,"No enable for new subscription" );
        require(msg.value == priceOfSubscription, "Incorect amount");
        
        payable(this).transfer(priceOfSubscription);
        
        maxNewSubscriptors = maxNewSubscriptors-1;
        lastSubscription = block.timestamp;
        controlTotalSubscriptors+=1;

       Subscription storage consult = subscriptions[msg.sender];

        if(!consult.active){
            controlNewSubscriptor+=1;
            subscriptions[msg.sender].nro = controlNewSubscriptor;
            subscriptions[msg.sender].controldate = block.timestamp;
            subscriptions[msg.sender].endsubscription = block.timestamp + 31 days;
            addressSubscriptors.push(msg.sender);
            emit NewRegisterSubscriptor(msg.sender, msg.value,block.timestamp, (block.timestamp + 31 days));
        }else{
            // si ya esta activo y tiene subscription
            subscriptions[msg.sender].endsubscription += 31 days;
        }
        
        
        subscriptions[msg.sender].amountSubscription += msg.value;
        subscriptions[msg.sender].active = true; 
        subscriptions[msg.sender].delegate = msg.sender;
        subscriptions[msg.sender].tikets+=1;
        
        if ( maxNewSubscriptors == 0 ) {
            newSubscriptionEnable = false;
        }
        
    
    }

    function comprarByToken() public payable {        
        require ( maxNewSubscriptors > 0 , "No have quota for new Subscription");  
        require ( newSubscriptionEnable == true,"No enable for new subscription" );
        require ( isActiveCustomToken == true,"No enable by token" );
        
        require ( token.balanceOf(address(msg.sender)) >= priceOfSubscription,"you need balance in topacio token" );
            
        // el approve debe invocarse primero por el from antes de comprar
        // para firmar la tansaaccion            
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= priceOfSubscription, "check the token allowance");                  
        token.transferFrom(msg.sender,address(this), priceOfSubscription);
         
        lastSubscription = block.timestamp;

        controlTotalSubscriptors+=1;

       Subscription storage consult = subscriptions[msg.sender];
        if(!consult.active) {
            maxNewSubscriptors = maxNewSubscriptors-1;
            controlNewSubscriptor+=1;
            subscriptions[msg.sender].nro = controlNewSubscriptor;
            subscriptions[msg.sender].controldate = block.timestamp;
            subscriptions[msg.sender].endsubscription = block.timestamp + 31 days;
            addressSubscriptors.push(msg.sender);
            emit NewRegisterSubscriptor(msg.sender, priceOfSubscription,block.timestamp, (block.timestamp + 31 days));
        }else{
            // si ya esta activo y tiene subscription
            subscriptions[msg.sender].endsubscription += 31 days;
        }
        
        subscriptions[msg.sender].amountSubscription += priceOfSubscription;
        subscriptions[msg.sender].active = true; 
        subscriptions[msg.sender].delegate = msg.sender;
        subscriptions[msg.sender].tikets+=1;
        
        if ( maxNewSubscriptors == 0 ) {
            newSubscriptionEnable = false;
        }
    }
 
    function tokensBalance() external view returns(uint256){
        return token.balanceOf(address(this));
    }

    function getTickets() external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       return consult.tikets;
    }

    function spendTickets(uint _countTicket) onlySubscriber external returns (bool){
       Subscription storage consult = subscriptions[msg.sender];
       require (consult.tikets>=_countTicket,"you not have enough Tickets");
       require (consult.tikets!=0 && _countTicket!=0,"Tickets cannot be zero");
       subscriptions[msg.sender].tikets = consult.tikets-_countTicket;
       emit NewSpendTickets(msg.sender, _countTicket,block.timestamp,block.number);
       return true;
    }

    function spendTicketsByCode(uint _countTicket,string memory _code) onlySubscriber external returns (bool){
       Subscription storage consult = subscriptions[msg.sender];
       require (consult.tikets>=_countTicket,"you not have enough Tickets");
       require (consult.tikets!=0 && _countTicket!=0,"Tickets cannot be zero");
       subscriptions[msg.sender].tikets = consult.tikets-_countTicket;
       emit NewSpendTicketsByCode(msg.sender, _countTicket, _code,block.timestamp,block.number);
       return true;
    }
    

    function assignTickets(uint _countTicket, address _addressSubscriber) onlyOwner external {
       Subscription storage consult = subscriptions[_addressSubscriber];
       require (consult.delegate == _addressSubscriber,"Subscriber no exist");
       require (_countTicket>0,"Tickets cannot be zero");
       subscriptions[_addressSubscriber].tikets += _countTicket;
    }

    function burnTickets(uint _countTicket, address _addressSubscriber) onlyOwner external {
       Subscription storage consult = subscriptions[_addressSubscriber];
       require (consult.tikets>=_countTicket,"you not have enough Tickets");
       require (consult.tikets!=0 && _countTicket!=0,"Tickets cannot be zero");
       consult.tikets = consult.tikets-_countTicket;
    }

    function getAllSubscriptions() onlyOwner external view returns (address[] memory) {
        return addressSubscriptors;
    }

    function getDateEndSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return consult.endsubscription;
    }

    function getDateInitialSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return consult.controldate;
    }

    function isSubscriber()  external view returns (bool){
       Subscription storage consult = subscriptions[msg.sender];
       return (consult.active);
    }

    function getDaysSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");          
       return (consult.endsubscription - block.timestamp) / 1 days;
    }

    function getHistoryAmountSubscriptions()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return (consult.amountSubscription);
    }

    function getSubscriptorNro()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return (consult.nro);
    }

    function searchSubscriptorNro(address _addressSubscriber)  external view returns (uint){
       Subscription storage consult = subscriptions[_addressSubscriber];
       return (consult.nro);
    }

    function getTotalSubscriptions()  external view returns (uint){
       return controlTotalSubscriptors;
    }

    function searchSubscriber(address _addressSubscriber)  external view returns (bool){
       Subscription storage consult = subscriptions[_addressSubscriber];
       return (consult.nro > 0);
    }

    function getStatusSubscriptionsRegister()  external view returns (bool){
       return newSubscriptionEnable;
    }

    function getSubscripcionesDisponibles()  external view returns (uint){
       return maxNewSubscriptors;
    }

    function getBalanceSuscriptions() onlyOwner external view returns (uint256){
       return address(this).balance;
    }

    function getStakingBalance() onlyOwner external view returns (uint256){
       return address(stakingInfrastructure).balance;
    }

    function getCosto() external view returns (uint256){
       return priceOfSubscription;
    }

    function updateCostSubscription( uint _new_cost ) onlyOwner public{
        priceOfSubscription = _new_cost;
    }

    function startingSubscriptions( uint _max_subscriptiors ) onlyOwner public{
        maxNewSubscriptors = _max_subscriptiors;  
        newSubscriptionEnable = true;
    }

    function stopRegistersSubscriptions( ) onlyOwner public{
        maxNewSubscriptors = 0;  
        newSubscriptionEnable = false;
    }

    function changeStaking( address _addressStaking ) onlyOwner public{
        stakingInfrastructure = payable(_addressStaking);
    }

    function toStakingInfrastructure() onlyOwner public payable {
        uint cantidad;    
       
       if(isActiveCustomToken==true) {
        cantidad = token.balanceOf(address(this));
        require( cantidad > 0,"contract not have enough balance");
        token.transfer(address(stakingInfrastructure),cantidad);
       }else{
        cantidad = address(this).balance;
        require(cantidad > 0,"contract not have enough balance");
        stakingInfrastructure.transfer(cantidad);
       }

       emit NewSendToStakingInfrastructure(address(stakingInfrastructure), cantidad, block.timestamp,block.number);

    }

    /* 
        implementacion pararecibir tokens solo el Owner puede depositar
        previniendo que envien cualquier cosa y cualquier gente
    */
    function onERC721Received(
        address, address, uint256, 
        bytes memory) onlyOwner public virtual override returns (bytes4){
        return this.onERC721Received.selector;
    }

    function setNFTsInstance(address _nftsCollection) onlyOwner public{
        instanceNFTs = IERC721Collection(_nftsCollection);
    }

    function setRateByClaim(uint _rate) onlyOwner public{
        rateByClaim = _rate;
    }

    /* Fragments logic */     
    function getFragmentHash() internal view returns (string memory) {

        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
            msg.sender))) % fragmentos.length; 
        
        return fragmentos[randomNumber];
    }

    function addHashFragment(string  memory _hash_fragment) onlyOwner public returns (uint) {
        fragmentos.push( _hash_fragment);
        return fragmentos.length;
    }

    function setHashFragment(string[] memory _hashes_fragment) onlyOwner public {
        fragmentos = _hashes_fragment;
    }

    function countsFragments() public view returns (uint) {
        return fragmentos.length;
    }

    function hashFragments() public view returns (string[] memory) {
        return fragmentos;
    }

    // <<--- Fragments logic ---<<

    function claimFragment() onlySubscriber external returns (uint256){
        require( availableFragments > 0,"no fragments available right now");
        require( subscriptions[msg.sender].tikets >= rateByClaim,"you do not have enough tickets");
        instanceNFTs.safeMint(msg.sender,getFragmentHash());
        uint idNFT = instanceNFTs.lastToken();
        availableFragments--;
        subscriptions[msg.sender].tikets = subscriptions[msg.sender].tikets-rateByClaim;
        emit RegisterClaimFragment(msg.sender,block.timestamp,block.number,idNFT);
       return subscriptions[msg.sender].tikets;
    }

}