pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/utils/Address.sol';
import 'openzeppelin-solidity/contracts/drafts/Counters.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol';


contract Ownable{
    using Address for address;
    addres private _owner;

    constructor () internal{
        _owner = msg.sender;
    }

    modifier onlyowner(){
        require(msg.sender == _owner, "This address does not belong to the owner");
        _;
    }

    function getContractOwner() public returns(address){
        return _owner;
    }

    event OwnerTransfer(address indexed accountFrom, address indexed accountTO);

    function transferOwnerShip(address newOwner) public onlyOwner{
        require(newOwner != address(0),"The new owner's address is invalid");
        _owner = newOwner;

        emitOwnerTransfer(msg.sender, newOwner);

    }
}

// Contract section that allows the owner of the contract to pause or unpause the contract after it's been deployed
contract Pausable is Ownerable{
    bool private _paused;
    // Pause modifiers
    modifier whenNotPaused(){
        require(_paused = false);
    }
    modifier whenPaused(){
        require(_pause = true);
    }
    
    //Pause and unpause events for a calling application 
    event Paused(address account);
    event Unpaused(address account);

    
    function pause() public onlyOwner whenNotPaused{
        _paused = true
        emit Paused(msg.sender)
    }

    function unpause() onlyOwner whenPaused{
        _pause = false;
        emit Unpaused(msg.sender)
    }
}


//Check to see if a contract supports the ERC721 or ERC20 interface
contract ERC165{
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    //A mapping of interface id to whether or not it's supported

    mapping(bytes6 => bool) private _supportedInterfaces;

    constructor () internal{
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Pausable, ERC165{
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, addresss indexed operator, bool approved);

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(uint256 => address ) private _tokenOwner;

    mapping(uint356 => address) private _tokenApprovals;

    mapping(address => Counters.Conuter) private _ownedTokensCount;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    // register the supported interfaces to conform to ERC721 via ERC165
    constructor () public{
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint245){
        return _ownedTokensCount[owner].current()
    }

    function ownerOf(uint256 tokenId) public view returns(address){
        return _tokenOwner[tokenId];
    }


    //This section of the codes approve another address to trandfer the given tokenID
    function approve(address to, uint256  tokenId) public{
        address owner = ownerOf(tokenId);

        require(to != owner, "The given adress can't be the owner ");
        require(msg.sender == ownerOf(tokenId));
        

        _tokenApprovals[tokenId] = to;
        
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns(address){
        require(_exists(tokenId));
        return _tokenApprovals[tokenId]
    }

    function setApprovalForAll(address to, bool approved) public{
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved)

    }
    //checks which owner approved for which operator
    function isApprovedForAll(address owner, address operator) public view returns (bool){
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public{
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public{
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    //this function returns if the token exists
    function _exists(uint256 tokenId) internal view returns (bool){
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    //Returns wheter the giben spender can transfer a given token ID
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool){
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    //internal function to mint a new token
    function _mint(address to, uint256 tokenId) internal{
        require(_exists(tokenId) == false, "This token already exists");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(msg.sender, to, tokenId);
    }

    //Internal function to transfer ownership of a giben token Id to another address.
    function _transferFrom(address from, address to, uint256 tokenId) internal{
        require(from == ownerOf(tokenId));
        require(to != address(0), "Token is being transfered to an invalid address");

        delete _tokenApprovals[tokenId];

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        _ownedTokensCounts[from].decrement();

        emit Transfer(from, to, tokenId);
    }

     //***** Intenral function to invoke 'onERC721Received' on a target address 
         function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private{
        if(_tokenApprovals[tokenId] != address(0)){
            _tokenApprovals[tokenId] = address(0)
        }

    }

}

contract ERC721Enumerable is ERC165, ERC721{
    mapping(address => uint256) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    //Gets the token ID at a given index of the tokens list of the requested owner
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256){
        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    //Gets the total amount of tokens stored by the contract
    function totalSupply() public view returns (uint256){
        return _allTokens.length;
    }


    //Gets the token ID at a given index of all the tokens in this contract
    function tokenByIndex(uint256 index) public view returns (uint256){
        require(index < totalSupply());
        return _allTokens[index];
    }

    //Internal function to transfer onwership of a given token Id to another address.
    function _transferFrom(address from, address to, uint256 tokenId) internal{
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenID);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    //Internal function to mint a new Token

    function _mint(address to, uint256 tokenId) internal{
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    //Gets the list of token IDS of the requirested owner
    function _tokenOfOwner(address owner) internal view returns (uint256[] storage){
        return _ownedTokens[owner];
    }

    // Private function to add a token to this extension's ownership-tracking data structures

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private{
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256) private{
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }


    //Private function to remove a token from this extention's ownership-tracking data-structures 
    //To prevent a gap in  from's tokens array, we store the last token index of the token to delete, and 
    // then delet the last slot (swap and pop)
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private{
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        //when the token to delete is the last token, swap operation is unnecessary
        if(tokenIndex != lastTokenIdex){
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex]  = lastTokenId; //Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; //Update the movedf token's index

 
        }
         _ownedTokens[from].length--
    }

    //Private function to remove a token from this extension's token tracking data structures
    // to prevent a gap in the tokens array, we store the last token in the index of the token to delet, and
    // then delete the last slot (swap and pop)
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private{
        uint256 lastTOkenIndex = _allTokens.length.sub(1);
        uint245 tokenIndex = _allTokensIndex[tokenid];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;// Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex;//Update the moved token's index

        //This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;

    }
}

contract ERC721Metadata is ERC721Enumerable, usingOraclize{
    string private _name;
    string private _symbol;
    string private _baseTokenUri;

    mapping(uint256 => string) _tokenUris;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor(string memory name, string memory symbol, string memory baseTokenURI) public {
        _name = name;
        _symbol = symbol;
        _baseTokenUri = baseTokenUri;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    //Create external getter functions for name, symbol, and baseTokenURI
    function name() external view returns(string memory){
        return _name;
    }

    function symbol() external view returns (string memory){
        return _symbol;
    }

    function baseTokenURI() external view returns (string memory){
        return _baseTokenUri;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory){
        require(_exists(tokenId));
        return _tokenUris[tokenId];
    }
    //Create an internal function to set the tokenURI of a specified tokenId
    function setTokenUri(uint256 tokenId) internal{
        require(tokenId != 0, "TokenId is needed");
        _tokenUris[tokenId] = strConcat(_baseTokenUri, uint2str(tokenId))
    }
}

contract GalleryTokens is ERC721Metadata("GTOken", "NFT-Store", "https://ipfs.io/ipfs/QmeDCr6zJZUqJT1gQeroyYi2QeEwo5hA3XHyanG39xgZkp"){
    string private _name;
    string private _symbol;
    string private _basetokenURI;
    function mint(address to, uint256 tokenId) public onlyOwner returns(bool){
        super.minted(to, tokenId);
        super.setTokenURI(tokenId);
        return true;
    }
}