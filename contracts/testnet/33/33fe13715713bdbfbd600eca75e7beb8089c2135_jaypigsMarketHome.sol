// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



import "./jaypigsTools.sol";
import { IAxelarGateway } from "./IAxelarGateway.sol";
import { IAxelarGasService } from "./IAxelarGasService.sol";
import { AxelarExecutable } from "./AxelarExecutable.sol";
import { StringToAddress, AddressToString } from "./StringAddressUtils.sol";
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */


contract jaypigsMarketHome is Ownable, AxelarExecutable {

    IAxelarGasService gasReceiver;
    IAxelarGateway _gateway;
    string public chainName;
    using StringToAddress for string;
    using AddressToString for address;

    error AlreadyInitialized();

    struct Listing {
        address seller;
        uint price;
        string pChain;
    }

    //mapping the seller address to the asset (nftAddress) and the to the tokenID
     mapping( address => mapping(uint => Listing)) private listings;
    //mapping the seller address to the asset (nftAddress) and the to the tokenID
     mapping( address => mapping(uint => Listing)) private paymentListings;
     //setting required address
     address gatewayAddress;

    modifier onlyAddress(address requiredAddress) {
         require(msg.sender==requiredAddress, "You are not allowed to call this function");
         _;
     }


    function init(
        string memory chainName_,
        address gateway_,
        address gasReceiver_
    ) external {
        if (address(_gateway) != address(0) || address(gasReceiver) != address(0)) revert AlreadyInitialized();
        gasReceiver = IAxelarGasService(gasReceiver_);
        _gateway = IAxelarGateway(gateway_);
        chainName = chainName_;
    }

    function gateway() public view override returns (IAxelarGateway) {
        return _gateway;
    }


    function List(address nftAddress, uint tokenId, uint price, string memory paymentChain) external {

        require(IERC721(nftAddress).ownerOf(tokenId)==msg.sender, "You are not the owner of this NFT");
        require(price>0, "Price can't be zero");
        require(IERC721(nftAddress).isApprovedForAll(msg.sender,address(this)));

        Listing memory newListing=Listing(msg.sender,price,paymentChain);
        listings[nftAddress][tokenId]=newListing;


    }

    function buy( address nftAddress, uint tokenId, string memory destinationChain, address destinationAddress, uint gasValue) external payable{

        require(gasValue<msg.value, "You did not pay enough gas for this transaction");
        string memory stringDestinationAddress = destinationAddress.toString();
        uint remainingValue=msg.value-gasValue;
        bytes memory payload=abi.encode(nftAddress, tokenId, msg.sender,remainingValue );
        gasReceiver.payNativeGasForContractCall{ value: gasValue }(address(this), destinationChain, stringDestinationAddress, payload, msg.sender);
        _gateway.callContract(destinationChain,stringDestinationAddress, payload );


    }

    function _execute(string memory sourceChain_,string memory sourceAddress_,bytes memory payload_) internal override {
        (address nftAddress, uint tokenId, address buyer, uint paidAmount) = abi.decode(
            payload_,
            (address, uint, address, uint)
        );

        IERC721(nftAddress).transferFrom(listings[nftAddress][tokenId].seller,buyer,tokenId);
    }


    receive() external payable {
            // React to receiving ether
    }
}