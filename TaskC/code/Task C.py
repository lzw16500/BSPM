# 1 - Import library
import pygame
import sys

# 2 - Initialize the game
pygame.init()
size = width, height = 451, 451
screen = pygame.display.set_mode(size)   # size of window

# 3 - Load images and set initial variables
background = pygame.image.load('background.png')
down = pygame.image.load('down.png')    # path and arrow
up = pygame.image.load('up.png')
right = pygame.image.load('right.png')
left = pygame.image.load('left.png')
path = pygame.image.load('down.png')
speed = 50          # move speed
x, y = 226, 226     # initial position
radius = 25         # robot
vector_x = 0        # move vector of x direction
vector_y = 0        # move vector of y direction

# 4 - initial the background and robot
# 4.1 - clear the window and initialize the background
screen.fill(pygame.Color('white'))
screen.blit(background, (0, 0))
# 4.2 - draw the robot
pygame.draw.circle(screen, pygame.Color('green'), (x, y), radius)
# 4.3 - draw the matrix grid 9x9
ROW = 9
COL = 9
cell_width = width / COL
cell_height = height / ROW
# draw row line of matrix grid
for r in range(ROW):
    pygame.draw.line(screen, pygame.Color('grey'), (0, r * cell_height), (width, r * cell_height))
# draw column line of matrix grid
for c in range(COL):
    pygame.draw.line(screen, pygame.Color('grey'), (c * cell_width, 0), (c * cell_width, height))
# 4.4 - update the screen
pygame.display.update()

# 5 - keep looping through
n = 0       # round
while n < 5:
    # 6 - draw the screen elements
    # 6.1 - draw the roboter and its path
    screen.blit(path, (x-vector_x-25, y-vector_y-25))
    pygame.draw.circle(screen, pygame.Color('green'), (x, y), radius)
    # 6.2 - draw the matrix grid
    for r in range(ROW):  # draw row line of matrix grid
        pygame.draw.line(screen, pygame.Color('grey'), (0, r * cell_height), (width, r * cell_height))
    for c in range(COL):  # draw column line of matrix grid
        pygame.draw.line(screen, pygame.Color('grey'), (c * cell_width, 0), (c * cell_width, height))
    # 7 - update the updated element
    # pygame.Rect((x_up_left,y_up_left),(delta_x_length,delta_t_height))
    rect1 = pygame.Rect((x-vector_x-25, y-vector_y-25),(50,50))
    rect2 = pygame.Rect((x-25, y-25), (50, 50))
    pygame.display.update(rect1)
    pygame.display.update(rect2)

    # 8 - loop through the events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
        # keys = pygame.key.get_pressed()
        if event.type == pygame.KEYDOWN:
            # left move
            if event.key == pygame.K_a or event.key == pygame.K_g or  \
                    event.key == pygame.K_m or event.key == pygame.K_s or event.key == pygame.K_y or  \
                    event.key == pygame.K_5:
                x -= speed
                vector_x = - speed
                vector_y = 0
                path = left
                n = n + 1
            # up move
            if event.key == pygame.K_b or event.key == pygame.K_h or  \
                    event.key == pygame.K_n or event.key == pygame.K_t or event.key == pygame.K_z or  \
                    event.key == pygame.K_6:
                y -= speed
                vector_x = 0
                vector_y = - speed
                path = up
                n = n + 1
            # right move
            if event.key == pygame.K_c or event.key == pygame.K_i or  \
                    event.key == pygame.K_o or event.key == pygame.K_u or event.key == pygame.K_1 or  \
                    event.key == pygame.K_7:
                x += speed
                vector_x = + speed
                vector_y = 0
                path = right
                n = n + 1
            # down move
            if event.key == pygame.K_d or event.key == pygame.K_j or  \
                    event.key == pygame.K_p or event.key == pygame.K_v or event.key == pygame.K_2 or  \
                    event.key == pygame.K_8:
                y += speed
                vector_x = 0
                vector_y = + speed
                path = down
                n = n + 1
            # repeat previous move
            if event.key == pygame.K_e or event.key == pygame.K_k or event.key == pygame.K_q or  \
                    event.key == pygame.K_w or event.key == pygame.K_3 or event.key == pygame.K_9:
                x += vector_x
                y += vector_y
                n = n + 1
            # do nothing
            if event.key == pygame.K_f or event.key == pygame.K_l or event.key == pygame.K_r or  \
                    event.key == pygame.K_x or event.key == pygame.K_4 or event.key == pygame.K_UNDERSCORE:
                vector_x = 0
                vector_y = 0
                n = n + 1


    # Control blocks do not go beyond the screen
    if x < 25:
        x = 25
    if x > 425:
        x = 425
    if y < 25:
        y = 25
    if y > 425:
        y = 425
