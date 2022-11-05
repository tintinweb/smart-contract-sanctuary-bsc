// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './ConfirmedOwner.sol';
import './VRFV2WrapperConsumerBase.sol';

interface IToken {
    function transfer(address _to, uint256 _value) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
}

contract RandomDistribution is VRFV2WrapperConsumerBase, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

    IToken public ticket721;
    event InitRandom(uint256 indexed sequenceId, uint256 requestId,uint256 randomV);
    mapping(address => bool) public minters;

    struct RequestStatus {
        uint256 paid; // amount paid in link
        uint256 sequenceId;
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    mapping(uint256 => uint256) public seeds;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 1;

    constructor(address _linkAddress,address _wrapperAddress) ConfirmedOwner(msg.sender) VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress) {}

    modifier onlyMint() {
        require( msg.sender == owner() || minters[msg.sender], "nft: not minter");
        _;
    }

    function setChainLinkParameter(uint32 _callbackGasLimit, uint16 _requestConfirmations, uint32 _numWords) public onlyOwner {
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        numWords = _numWords;
        //fee = _fee * 10 ** 16; // 0.2 LINK (Varies by network)
    }

    function setMinters(address _address, bool _allow) public onlyOwner {
        require(_address != address(0), "nft: zero_address");
        require(minters[_address] != _allow, "nft: no edit");
        minters[_address] = _allow;
    }

    function setTicket(address _ticketToken) external onlyOwner() {
        require(_ticketToken != address(0), "The token's address cannot be 0");
        ticket721 = IToken(_ticketToken);
    }
    function requestRandomWords(uint256 _sequenceId) external onlyMint() returns (uint256 requestId) {
        require(seeds[_sequenceId] == 0, "Do not repeat  acquire");
        requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            sequenceId: _sequenceId,
            randomWords: new uint256[](0),
            fulfilled: false
            });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].paid > 0, 'request not found');
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        seeds[s_requests[_requestId].sequenceId] = _randomWords[0] ;
        emit RequestFulfilled(_requestId, _randomWords, s_requests[_requestId].paid);
        emit InitRandom(s_requests[_requestId].sequenceId,_requestId,_randomWords[0]);
    }

    function getRequestStatus(uint256 _requestId)
    external
    view
    returns (
        uint256 paid,
        uint256 sequenceId,
        bool fulfilled,
        uint256[] memory randomWords
    )
    {
        require(s_requests[_requestId].paid > 0, 'request not found');
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.sequenceId,request.fulfilled, request.randomWords);
    }

    function getRandomSeed(uint256 sequenceId) public view returns (uint256) {
        return seeds[sequenceId];
    }

    // withdraw token for rollback
    function withdrawToken(address token, address payable dest, uint amount) public onlyOwner{
        if (token == address(0x0))
            dest.transfer(amount);
        else
            IToken(token).transfer(dest, amount);
    }

    // receive() external payable {}/* can accept ether */
}