// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Marketplace.sol";

contract MarketplaceAuction is Marketplace {
    //currency medamon
    struct Listing {
        address lister;
        uint256 initialPrice;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(IERC721 => mapping(uint256 => Listing)) public listings;
    mapping(IERC721 => mapping(uint256 => Listing)) public especialListings;

    uint public minTimeToAddPlus; //Tiempo minimo para a contemplar para agregar mas tiempo a la subasta
    uint public timePlus;//Tiempo que se agrega tras una puja
    uint public minEndTime; //tiempo que debe Manterse como minimo, en segundos.

    uint public bidFee = 1; //Minimo que debe superar la puja entrante, respecto de la puja actual.

    event Listed(address lister, IERC721 token, uint256 tokenId, uint256 initialPrice, uint256 endTime);
    event Bid(address bidder, IERC721 token, uint256 tokenId, uint256 amount);
    event Unlisted(address lister, IERC721 token, uint256 tokenId);    
    event Claim(address purchaser, address lister, IERC721 token, uint256 tokenId, uint256 endPrice);


    constructor(
        IERC721[] memory _whitelistedTokens,
        IERC20 _currency,
        address _feeTo,
        address _liquidity,
        uint256 _feePercentage,
         uint256 _feeLiquidity
    ) Marketplace(_whitelistedTokens, _currency) FeeBeneficiary(_feeTo, _liquidity, _feePercentage, _feeLiquidity) {}

    modifier bidAmountMeetsBidRequirements(
        IERC721 _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) {
        require(
            _doesBidMeetBidRequirements(
                _nftContractAddress,
                _tokenId,
                _tokenAmount
            ),
            "Not enough funds to bid on NFT"
        );
        _;
    }

    /********************
    *  PUBLIC FUNCTIONS *
    *********************/

    function list(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _biddingTime
    ) public whenNotPaused onlyWhitelistedTokens(_token) {
        Listing storage listing = listings[_token][_tokenId];
        require(_token.ownerOf(_tokenId) == msg.sender, "MARKETPLACE: Caller is not token owner");
        _token.transferFrom(msg.sender, address(this), _tokenId);

        Listing memory newListing = Listing({
            lister: msg.sender,
            initialPrice: _initialPrice,
            endTime: block.timestamp + _biddingTime,
            highestBidder: msg.sender,
            highestBid: 0
        });
        listings[_token][_tokenId] = newListing;
        emit Listed(msg.sender, _token, _tokenId, _initialPrice, listing.endTime);
    }

    //modificado en linea 75. Agrega suma de tiempo si la subasta esta por terminar
    function bid(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _amount
    )   public
        whenNotPaused 
        onlyWhitelistedTokens(_token)
        bidAmountMeetsBidRequirements(
            _token,
            _tokenId,
            _amount
        )
    {
        //cambiar a memory
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister != address(0), "MARKETPLACE: Token not listed");
        require(listing.lister != msg.sender, "MARKETPLACE: Can't bid on your own token");
        require(block.timestamp < listing.endTime, "MARKETPLACE: Bid too late");
        require(_amount > listing.highestBid, "MARKETPLACE: Bid lower than previous bid");
        require(_amount > listing.initialPrice, "MARKETPLACE: Bid lower than initialPrice");

        if (listing.highestBid != 0) {
            currency.transferFrom(address(this), listing.highestBidder, listing.highestBid);
        }

        currency.transferFrom(msg.sender, address(this), _amount);

        listing.highestBid = _amount;
        listing.highestBidder = msg.sender;

        if(_getTimeLeft(listing.endTime) < minTimeToAddPlus){
            listing.endTime += timePlus;
            //agrega tiempo fijo tras una puja, por debajo de minTimeToAddPlus
        }

        listing.endTime +=difTimeToend(listing.endTime);
        //Mantiene un tiempo minimo tras una puja.

        emit Bid(msg.sender, _token, _tokenId, _amount);
    }

    //Permite reclamar los resultados de una subasta terminada.
    function claim(IERC721 _token, uint256 _tokenId) public whenNotPaused{
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister != address(0), "MARKETPLACE: Token not listed");
        require(_getClaimers(msg.sender,listing), "MARKETPLACE: Can settle only your own token");
        require(block.timestamp > listing.endTime, "MARKETPLACE: endTime not reached");

        uint256 endPrice = listing.highestBid;
        uint256 resultingAmount = _getResultingAmount(endPrice, currency);

        currency.transfer(listing.lister, resultingAmount);
        _token.transferFrom(address(this), listing.highestBidder, _tokenId);

        _unlist(_token, _tokenId);
        emit Claim(listing.highestBidder, listing.lister, _token, _tokenId, endPrice);

    }

    //Permite quitar un nft de subasta solo si, nadie pujo por el.
    function unlist(IERC721 _token, uint256 _tokenId) public {
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister == msg.sender);
        require(listing.highestBidder == listing.lister);
        _unlist(_token, _tokenId);
    }
    //permite cambiar el precio minimo de puja, solo si, nadie pujo por el nft.
    function changePrice(IERC721 _token, uint256 _tokenId, uint _initialPrice) public {
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister == msg.sender);
        require(listing.highestBidder == listing.lister);
        listing.initialPrice = _initialPrice;
        //emit changePrice
    }

    /* Regresa la diferencia entre el tiempo que le queda a la subasta, con el minEndTime
    *  usar en la funcion de puja, para sumar al endTime, el tiempo retornado por esta funcion.
    */
    function difTimeToend(uint _endTime) public view returns(uint){
        uint timeLeft = _getTimeLeft(_endTime);
        if(minEndTime > timeLeft) {
            // si el tiempo restante es menor, regresa la difrencia que se le debe sumar a endTime;
            return minEndTime - timeLeft;
        }
        return 0; //Si el tiempo es mayor, retorna 0, porque no se debe sumar ningun segundo.
    }

    function setBidFee(uint _bidFee) external onlyOwner{
        bidFee = _bidFee;
    }

    function setMinEndTime(uint _timeInSegs) public onlyOwner{
        minEndTime = _timeInSegs;
    }


    /**flashImplement: editado del normal list */
    function especialList(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _biddingTime
    ) public whenNotPaused  {
        Listing storage listing = especialListings[_token][_tokenId];
        require(_token.ownerOf(_tokenId) == msg.sender, "MARKETPLACE: Caller is not token owner");
        _token.transferFrom(msg.sender, address(this), _tokenId);

        Listing memory newListing = Listing({
            lister: msg.sender,
            initialPrice: _initialPrice,
            endTime: block.timestamp + _biddingTime,
            highestBidder: msg.sender,
            highestBid: 0
        });
        especialListings[_token][_tokenId] = newListing;
        emit Listed(msg.sender, _token, _tokenId, _initialPrice, listing.endTime);
    }



    /********************
    *INTERNAL FUNCTIONS *
    *********************/
    //Regresa tiempo restante de una subasta, para hacerlo publico modifcar parametreo de entrada
    function _getTimeLeft(uint _endTime) internal view returns(uint){
        return _endTime - block.timestamp;
    }

    //Regresa true si quien llama es el listador o  el ganador, de una subasta.
    function _getClaimers(address _sender, Listing memory _listing) internal pure returns(bool){
        if( (_sender == _listing.lister) || (_sender == _listing.highestBidder)){
            return true;
        }else{
            return false;
        }
    }

    //Quita el nft de una subasta. Borra los datos del mapping
    function _unlist(IERC721 _token, uint256 _tokenId) internal {
        delete listings[_token][_tokenId];
        emit Unlisted(msg.sender, _token, _tokenId);
    }  

    /*
     * An auction: the bid needs to be a bidFee% higher than the previous bid.
     */
    function _doesBidMeetBidRequirements(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal view returns (bool) {        
        //if the NFT is up for auction, the bid needs to be a % higher than the previous bid
        uint256 bidIncreaseAmount = (listings[_token][_tokenId].highestBid * bidFee) / 100
            + listings[_token][_tokenId].highestBid;
        return   (_tokenAmount >= bidIncreaseAmount);
    }


    /*TODO:
    * Tiempo fijo de suma.
    * views.
    */
}