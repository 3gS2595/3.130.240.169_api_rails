import re

text = "057/ca7c660514e0d6af-1b/s100x200/800ca94778a0a70498eb909a873d2049e1910c78.jpg 100w, https://64.media.tumblr.com/f08de014b13ed8a6c8b099cb23a70057/ca7c660514e0d6af-1b/s250x400/f021b263d22d3ac7a3ad2957ad25844274b936fa.pnj 250w, https://64.media.tumblr.com/f08de014b13ed8a6c8b099cb23a70057/ca7c660514e0d6af-1b/s400x600/1f77f6fb0368ec9a482b01ebbc4ba0d4fc4ae75d.pnj 400w, https://64.media.tumblr.com/f08de014b13ed8a6c8b099cb23a70057/ca7c660514e0d6af-1b/s500x750/e4c6e47c42ea3a182a73f4b8d8ebfd8ed65aa96b.jpg 500w, https://64.media.tumblr.com/f08de014b13ed8a6c8b099cb23a70057/ca7c660514e0d6af-1b/s540x810/c4b21d2e5ac4ed2655eabf7f15836931ad367d0c.pnj 540w, https://64.media.tumblr.com/f08de014b13ed8a6c8b099cb23a70057/ca7c660514e0d6af-1b/s640x960/8365c132dfd62f59f14c1c450958f830af3a264d.jpg 637wI, [2023-07-15 15:29:43 -0600#18957] [M: 780]  INFO -- github_spider: Browser: started get request to: https://www.tumblr.com/7twdi29ot5y8og6ndze7m7wexn29cm24/71995866576809164"
pattern = r"https?://[^/\s]+/\S+\.jpg"
image_urls = re.findall(pattern, text)

print(image_urls)

