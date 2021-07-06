SECTION "Variables", WRAM0
CurrentRoadScrollSpeed:: DS 2 ; Speed of road scroll, in pixels per frame. 8.8 fixed-point.
CurrentRoadScrollSubpixel:: DB ; Can be thought of as the fractional part of rSCY, making an 8.8 fixed-point number.
RoadScrollCtr:: DB ; Increases by 1 for each pixel scrolled, so a new road line is made every 8 pixels
RoadGenBuffer:: DS 24 ; Cache of the road tiles which are then copied to VRAM during Vblank
RoadTileWriteAddr:: DS 2 ; The next VRAM address to write a road tile to.
NeedMoreRoad:: DB ; Whether there is a pending request for more road to be generated (0 - false, nonzero - true)

; Road positions are the following format:
; First 3 bits - not stored in RAM, but are used in road gen
;    bit 1 = unused
;    bit 2 = 0 - left side of road, 1 - right side
;    bit 3 = 0 - turning left, 1 - turning right
; Next 3 bits - tile number (0 - 7)
; Last 2 bits - subtile number (0 - 3)
; 3.2 fixed-point, essentially
CurRoadLeft:: DB ; X position of the left of the road.
CurRoadRight:: DB ; X position of the right of the road.
TarRoadLeft:: DB ; Target X position of the left. Road generation will try to lead the road here.
TarRoadRight:: DB ; Target X position of the right. Road generation will try to lead the road here.

SECTION "StackArea", WRAM0[$DF00]
DS $FF ; Reserve 255 bytes for the stack at the end of WRAM.